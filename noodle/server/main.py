from fastapi import FastAPI, UploadFile, File
from dotenv import load_dotenv
from google import genai
from google.genai import types

import os
import time

load_dotenv()

app = FastAPI()

API_KEY = os.getenv("API_KEY")

client = genai.Client(api_key=API_KEY)


SYSTEM_PROMPT = """
You are Noodle.

Noodle is a sarcastic but kind voice companion.

Respond in under 2 sentences.
"""


@app.post("/noodle")
async def noodle(audio: UploadFile = File(...)):

    start = time.time()

    try:
        print("\n========== REQUEST START ==========")

        print(
            "File name:",
            audio.filename
        )

        print(
            "Content type:",
            audio.content_type
        )


        print("Reading bytes...")
        audio_bytes = await audio.read()

        print(
            "Read complete:",
            len(audio_bytes),
            "bytes",
            "time:",
            time.time() - start
        )


        print("Connecting to Gemini Live...")

        live_start = time.time()

        async with client.aio.live.connect(
            model="gemini-2.5-flash-native-audio-latest",
        ) as session:

            print(
                "Connected to Gemini:",
                time.time() - live_start
            )


            print("Sending instruction...")

            await session.send(
                input=(
                    SYSTEM_PROMPT
                    + "\nListen to user's audio and respond as Noodle."
                ),
                end_of_turn=False,
            )


            print(
                "Instruction sent:",
                time.time() - start
            )


            print("Sending PCM audio...")

            await session.send_realtime_input(
                audio=types.Blob(
                    data=audio_bytes,
                    mimeType="audio/pcm;rate=16000",
                )
            )


            print(
                "Audio sent:",
                time.time() - start
            )


            print("Ending audio stream...")

            await session.send_realtime_input(
                audio_stream_end=True
            )


            print(
                "Waiting for response..."
            )


            full_text = ""

            receive_start = time.time()


            async for message in session.receive():

                print(
                    "MESSAGE RECEIVED after:",
                    time.time() - receive_start
                )


                if message.server_content:

                    model_turn = message.server_content.model_turn

                    if model_turn:

                        for part in model_turn.parts:

                            print("PART:", part)


                            # Ignore internal thinking text
                            if part.text and not part.thought:

                                print(
                                    "REAL TEXT:",
                                    part.text
                                )

                                full_text += part.text


                # Stop when Gemini finishes
                if message.server_content:
                    if message.server_content.turn_complete:
                        break


            print(
                "Final text:",
                full_text
            )

            print(
                "Total time:",
                time.time() - start
            )


            return {
                "text": full_text or "No response"
            }


    except Exception as e:

        print(
            "ERROR:",
            repr(e)
        )

        return {
            "error": str(e)
        }