from fastapi import FastAPI, UploadFile, File
from fastapi.responses import Response
from dotenv import load_dotenv

from fastapi import WebSocket, WebSocketDisconnect
import os

from services.noodle_websocket_service import NoodleWebSocketService
load_dotenv()

app = FastAPI()

API_KEY = os.getenv("API_KEY")


@app.websocket("/ws/noodle")
async def noodle_socket(
    websocket: WebSocket,
):
    await websocket.accept()

    print("WebSocket connected")
    ws_service = NoodleWebSocketService(API_KEY)

    try:

        await ws_service.process_stream(
            websocket
        )

    except WebSocketDisconnect:

        print(
            "WebSocket disconnected"
        )

    except Exception as e:

        print(
            f"WebSocket Error: {repr(e)}"
        )

        try:
            await websocket.close()
        except:
            pass
