from google import genai
from google.genai import types
from google.api_core.exceptions import GoogleAPIError, PermissionDenied, ResourceExhausted, InvalidArgument

from utils.audio_conversion import pcm_to_wav


SYSTEM_PROMPT = """
You are Noodle.
Your job is to help that overthinker out of their head with a small fun response. Like a friend who roasts you when you overthink.
Be gentle but roast.
Listen to user audio and reply as Noodle.
And say you are noodle if the user asks about you say I get you out of your head.
"""


class NoodleError(Exception):
    """Raised for known, user-facing errors — message is sent directly to the client."""
    pass


class NoodleWebSocketService:

    def __init__(self, api_key: str):
        self.client = genai.Client(api_key=api_key)

    async def process_stream(self, websocket):
        print("\n========== WS REQUEST START ==========")

        # ── Connect to Gemini ──
        try:
            live_context = self.client.aio.live.connect(
                model="gemini-2.5-flash-native-audio-latest",
                config=types.LiveConnectConfig(
                    system_instruction=SYSTEM_PROMPT,
                    response_modalities=["AUDIO"],
                ),
            )
        except PermissionDenied:
            raise NoodleError("Your Gemini API key is invalid or doesn't have access. Check your settings.")
        except Exception as e:
            raise NoodleError(f"Couldn't connect to Gemini: {repr(e)}")

        async with live_context as session:
            print("Gemini connected")

            # ── Receive microphone chunks from Flutter ──
            try:
                while True:
                    message = await websocket.receive()

                    if message.get("bytes"):
                        chunk = message["bytes"]
                        await session.send_realtime_input(
                            audio=types.Blob(
                                data=chunk,
                                mimeType="audio/pcm;rate=16000",
                            )
                        )

                    elif message.get("text"):
                        text = message["text"]
                        print(f"Received text: {text}")

                        if text == "END":
                            print("Audio stream finished. Waiting for Gemini...")
                            await session.send_realtime_input(audio_stream_end=True)
                            break

            except Exception as e:
                raise NoodleError(f"Error receiving audio from client: {repr(e)}")

            # ── Collect Gemini's response ──
            output_audio = bytearray()

            try:
                async for message in session.receive():
                    print("\n=== GEMINI MESSAGE ===")
                    print(message)
                    print("======================")

                    if not message.server_content:
                        continue

                    model_turn = message.server_content.model_turn
                    if model_turn:
                        for part in model_turn.parts:
                            if hasattr(part, "inline_data") and part.inline_data:
                                output_audio.extend(part.inline_data.data)

                    if message.server_content.turn_complete:
                        print("Gemini turn complete")
                        break

            except ResourceExhausted:
                raise NoodleError(
                    "You've hit the Gemini API quota. "
                    "Try again later or add your own API key in settings."
                )
            except PermissionDenied:
                raise NoodleError("Your Gemini API key was rejected. Please check it in settings.")
            except InvalidArgument as e:
                raise NoodleError(f"Invalid request to Gemini: {e}")
            except GoogleAPIError as e:
                raise NoodleError(f"Gemini API error: {e.message}")
            except Exception as e:
                raise NoodleError(f"Unexpected error while getting Gemini response: {repr(e)}")

            if not output_audio:
                raise NoodleError("Noodle didn't generate any audio. Try speaking a bit longer.")

            # ── Convert and send back ──
            print(f"Generated audio: {len(output_audio)} bytes")

            try:
                wav_audio = pcm_to_wav(bytes(output_audio), sample_rate=24000)
            except Exception as e:
                raise NoodleError(f"Failed to convert audio: {repr(e)}")

            print(f"WAV size: {len(wav_audio)} bytes")

            try:
                await websocket.send_bytes(wav_audio)
            except Exception as e:
                raise NoodleError(f"Failed to send audio to client: {repr(e)}")

            print("Response sent to Flutter")
            print("========== WS REQUEST END ==========\n")