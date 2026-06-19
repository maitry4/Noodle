from fastapi import FastAPI, UploadFile, File
from fastapi.responses import Response
from dotenv import load_dotenv

from services.noodle_service import NoodleService

import os


load_dotenv()

app = FastAPI()

API_KEY = os.getenv("API_KEY")

noodle_service = NoodleService(API_KEY)
@app.post("/noodle")
async def noodle(audio: UploadFile = File(...)):
    audio_bytes = await audio.read()
    wav_audio = await noodle_service.process_audio(
        audio_bytes=audio_bytes,
        filename=audio.filename,
        mime_type=audio.content_type,
    )

    return Response(
        content=wav_audio,
        media_type="audio/wav",
        headers={
            "Content-Disposition":
            "attachment; filename=noodle.wav"
        },
    )