import os

from fastapi import FastAPI, WebSocket, WebSocketDisconnect
from dotenv import load_dotenv

from services.noodle_websocket_service import NoodleWebSocketService, NoodleError
from services.rate_limiter import check_rate_limit
from services.stats_service import increment_rant_resolved, get_rant_resolved
from services.db import init_db
from fastapi.middleware.cors import CORSMiddleware

load_dotenv()

init_db()

app = FastAPI()

SHARED_API_KEY = os.getenv("API_KEY")


app.add_middleware(
    CORSMiddleware,
    allow_origins=["https://maitry4.github.io"],
    allow_methods=["GET"],
)
@app.get("/stats")
def stats():
    return {"rant_resolved": get_rant_resolved()}


@app.websocket("/ws/noodle")
async def noodle_socket(websocket: WebSocket):
    await websocket.accept()

    device_uuid: str = websocket.query_params.get("device_uuid", "")
    user_api_key: str | None = websocket.query_params.get("api_key") or None
    language_code: str = websocket.query_params.get("language_code", "en-US")


    try:
        if user_api_key:
            api_key_to_use = user_api_key
        else:
            if not device_uuid:
                await websocket.send_text("ERROR: Missing device_uuid.")
                await websocket.close()
                return

            if not check_rate_limit(device_uuid):
                await websocket.send_text(
                    "You've reached your 10 free requests for today. "
                    "Add your own Gemini API key in settings to keep going."
                )
                await websocket.close()
                return

            if not SHARED_API_KEY:
                await websocket.send_text("ERROR: Server is not configured. Please try again later.")
                await websocket.close()
                return

            api_key_to_use = SHARED_API_KEY

        ws_service = NoodleWebSocketService(api_key_to_use, language_code)
        await ws_service.process_stream(websocket)

        increment_rant_resolved()

    except WebSocketDisconnect:
        pass

    except NoodleError as e:
        try:
            await websocket.send_text(str(e))
            await websocket.close()
        except Exception:
            pass

    except Exception as e:
        try:
            await websocket.send_text("ERROR: Something went wrong on our end. Please try again.")
            await websocket.close()
        except Exception:
            pass

        