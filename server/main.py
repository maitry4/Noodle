import os
import base64
from fastapi import FastAPI, UploadFile, File, Form, Header, HTTPException, Response
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional

from services.noodle_service import NoodleService

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

noodle_service = NoodleService()

@app.post("/noodle")
async def process_noodle(
    audio: UploadFile = File(...)
):
    audio_bytes = await audio.read()
    if not audio_bytes:
        raise HTTPException(status_code=400, detail="Missing audio file")
        
    final_api_key = os.getenv("NOODLE_API_KEY")
    if not final_api_key:
        raise HTTPException(status_code=500, detail="Server misconfiguration: No API key available")
        
    try:
        result = noodle_service.process(audio_bytes, final_api_key)
        if result["audio_b64"]:
            audio_data = base64.b64decode(result["audio_b64"])
            return Response(content=audio_data, media_type="audio/wav")
        else:
            raise HTTPException(status_code=500, detail="No audio returned from Gemini")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))