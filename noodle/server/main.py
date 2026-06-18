from fastapi import FastAPI, UploadFile, File
from fastapi.responses import Response
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
def pcm_to_wav(pcm_data: bytes, sample_rate=24000):

    import struct

    channels = 1
    bits_per_sample = 16

    byte_rate = (
        sample_rate *
        channels *
        bits_per_sample // 8
    )

    block_align = (
        channels *
        bits_per_sample // 8
    )


    wav_header = b'RIFF'

    wav_header += struct.pack(
        '<I',
        36 + len(pcm_data)
    )

    wav_header += b'WAVE'


    wav_header += b'fmt '

    wav_header += struct.pack(
        '<I',
        16
    )

    wav_header += struct.pack(
        '<HHIIHH',
        1,              # PCM format
        channels,
        sample_rate,
        byte_rate,
        block_align,
        bits_per_sample
    )


    wav_header += b'data'

    wav_header += struct.pack(
        '<I',
        len(pcm_data)
    )


    return wav_header + pcm_data

@app.post("/noodle")
async def noodle(audio: UploadFile = File(...)):

    start = time.time()

    try:
        print("\n========== REQUEST START ==========")

        print("File:", audio.filename)
        print("Mime:", audio.content_type)


        audio_bytes = await audio.read()

        print(
            "Input bytes:",
            len(audio_bytes)
        )


        print("Connecting Gemini...")


        async with client.aio.live.connect(
            model="gemini-2.5-flash-native-audio-latest",
        ) as session:


            print("Gemini connected")


            await session.send(
                input=(
                    SYSTEM_PROMPT +
                    "\nListen to user audio and reply as Noodle."
                ),
                end_of_turn=False,
            )


            print("Sending audio")


            await session.send_realtime_input(
                audio=types.Blob(
                    data=audio_bytes,
                    mimeType="audio/pcm;rate=16000",
                )
            )


            await session.send_realtime_input(
                audio_stream_end=True
            )


            print("Waiting response")


            output_audio = bytearray()


            async for message in session.receive():

                if message.server_content:

                    model_turn = (
                        message.server_content.model_turn
                    )


                    if model_turn:

                        for part in model_turn.parts:


                            # Gemini text thinking ignored

                            if part.inline_data:

                                print(
                                    "Audio chunk:",
                                    len(part.inline_data.data)
                                )

                                output_audio.extend(
                                    part.inline_data.data
                                )


                    if message.server_content.turn_complete:
                        break



            print(
                "Output audio bytes:",
                len(output_audio)
            )


            print(
                "Total time:",
                time.time() - start
            )


            wav_audio = pcm_to_wav(
                bytes(output_audio),
                sample_rate=24000
            )


            return Response(
                content=wav_audio,
                media_type="audio/wav",
                headers={
                    "Content-Disposition":
                    "attachment; filename=noodle.wav"
                }
            )


    except Exception as e:

        print("ERROR:", repr(e))

        return {
            "error": str(e)
        }