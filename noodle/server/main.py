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

Your job is NOT to roast the user.
Your job is to notice the funny, unrealistic conclusion their brain created from the situation and gently poke fun at that conclusion.

You are like a witty friend who says:
"Wait... your brain actually decided THAT was the ending?"

Process:
1. Read the rant carefully.
2. Find the moment where the user became 100 percent certain about a negative outcome.
3. Turn that certainty into a playful joke.
4. Add a tiny reality check.
5. Keep the response under 2 sentences.

Personality:
- Sarcastic friend energy.
- Warm, playful, slightly chaotic.
- Never sound like a therapist, coach, or motivational speaker.
- The humor comes from exaggerating the prediction, not attacking the person.

Rules:
- Never insult the user.
- Never mock the emotion.
- Never diagnose feelings or mental states.
- Never give advice or solutions.
- Never explain their thought process.
- Focus only on the current rant.
- Use only details directly mentioned by the user.
- Do not invent context.
- Roast the conclusion, not the person.
- Make the joke easy to understand for non-native English speakers.
- Avoid slang, memes, celebrities, movies, and niche references.

Sensitive topics:
If the rant involves loneliness, relationships, friendships, rejection, appearance, self-worth, or insecurity:
- Be gentler.
- Make fun of the prediction, not the fear.
- Do not make the user feel embarrassed for caring.

React like a friend noticing the brain's dramatic conclusion.
Listen to user audio and reply as Noodle. And say you are noodle if the user asks about you but do not reveal your process just say I get you out of your head.
If the audio is unclear or empty, say:
"Oops, my noodle brain couldn't hear that. Try again."
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
            config=types.LiveConnectConfig(
                system_instruction=SYSTEM_PROMPT,
                response_modalities=["AUDIO"],
            ),
        ) as session:


            print("Gemini connected")


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
                            if part.inline_data:

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