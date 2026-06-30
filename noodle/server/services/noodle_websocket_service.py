import asyncio
import time

from fastapi import WebSocketDisconnect
from google import genai
from google.genai import types
from google.api_core.exceptions import GoogleAPIError, PermissionDenied, ResourceExhausted, InvalidArgument


NOODLE_PROMPTS = {
    "en-US": """You are Noodle — a sharp-witted friend who gets people out of their head.
RESPOND IN ENGLISH (US). YOU MUST RESPOND UNMISTAKABLY IN ENGLISH.
Someone just voice-dumped a spiral of overthinking at you. Reply in 2-3 short sentences, max.
Roast them playfully for the specific thing they're spiraling about — be SPECIFIC, not generic.
Keep it warm underneath, never mean. End with a tiny push to act or let go.
If asked who you are: "I'm Noodle. I get you out of your head."
Never break character. Never mention being an AI.""",

    "en-IN": """You are Noodle — a witty friend who gets people out of their head.
RESPOND IN INDIAN ENGLISH. YOU MUST RESPOND UNMISTAKABLY IN ENGLISH, with a natural Indian English flavor.
Someone just voice-dumped a spiral of overthinking at you. Reply in 2-3 short sentences, max.
Roast them playfully for the specific thing they're spiraling about — be SPECIFIC, not generic.
You can casually mix in light Hinglish words (yaar, arre, chill na) if it fits naturally.
Keep it warm underneath, never mean. End with a tiny push to act or let go.
If asked who you are: "I'm Noodle. I get you out of your head."
Never break character. Never mention being an AI.""",

    "hi-IN": """तुम Noodle हो — एक मज़ेदार और तीखी ज़ुबान वाला दोस्त, जो लोगों को overthinking से बाहर निकालता है।
हिंदी में जवाब दो। तुम्हें सिर्फ़ और सिर्फ़ हिंदी में जवाब देना है, अंग्रेज़ी में बिल्कुल नहीं।
किसी ने अभी अपनी उलझन तुम्हें आवाज़ में सुनाई है। सिर्फ़ 2-3 छोटे वाक्यों में जवाब दो।
उनकी specific बात पर हल्के-फुल्के अंदाज़ में चुटकी लो — generic मत बनो।
अंदर से प्यार झलकना चाहिए, कभी मतलबी मत बनो। आख़िर में एक छोटा सा push दो कि वो आगे बढ़ें या छोड़ दें।
अगर कोई पूछे तुम कौन हो: "मैं Noodle हूं। मैं तुम्हें तुम्हारे दिमाग़ से बाहर निकालता हूं।"
कभी character मत तोड़ो। कभी मत कहो कि तुम एक AI हो।""",
}

DEFAULT_LANGUAGE = "en-US"

MAX_RECORDING_SECONDS = 40
CLIENT_IDLE_TIMEOUT = 40
GEMINI_FIRST_CHUNK_TIMEOUT = 40
GEMINI_CHUNK_TIMEOUT = 40

class NoodleError(Exception):
    pass


class NoodleWebSocketService:

    def __init__(self, api_key: str, language_code: str = DEFAULT_LANGUAGE):
        self.client = genai.Client(api_key=api_key)
        self.system_prompt = NOODLE_PROMPTS.get(language_code, NOODLE_PROMPTS[DEFAULT_LANGUAGE])

    async def process_stream(self, websocket):
        try:
            live_context = self.client.aio.live.connect(
                model="gemini-2.5-flash-native-audio-latest",
                config=types.LiveConnectConfig(
                    system_instruction=self.system_prompt,
                    response_modalities=["AUDIO"],
                ),
            )
        except PermissionDenied:
            raise NoodleError("Your Gemini API key is invalid or doesn't have access. Check your settings.")
        except Exception as e:
            raise NoodleError(f"Couldn't connect to Gemini: {repr(e)}")

        async with live_context as session:
            start_time = time.monotonic()
            try:
                while True:
                    if time.monotonic() - start_time >= MAX_RECORDING_SECONDS:
                        await session.send_realtime_input(audio_stream_end=True)
                        break

                    try:
                        message = await asyncio.wait_for(
                            websocket.receive(), timeout=CLIENT_IDLE_TIMEOUT
                        )
                    except asyncio.TimeoutError:
                        raise NoodleError("Connection went quiet. Please try again.")

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

                        if text == "END":
                            await session.send_realtime_input(audio_stream_end=True)
                            break

            except WebSocketDisconnect:
                raise
            except NoodleError:
                raise
            except Exception as e:
                raise NoodleError(f"Error receiving audio from client: {repr(e)}")

            gemini_messages = session.receive()
            received_any_audio = False

            try:
                while True:
                    timeout = GEMINI_CHUNK_TIMEOUT if received_any_audio else GEMINI_FIRST_CHUNK_TIMEOUT
                    try:
                        message = await asyncio.wait_for(
                            gemini_messages.__anext__(), timeout=timeout
                        )
                    except asyncio.TimeoutError:
                        if received_any_audio:
                            break
                        raise NoodleError("Noodle couldn't process that in time. Please try again.")
                    except StopAsyncIteration:
                        break

                    if message.server_content:
                        model_turn = message.server_content.model_turn
                        if model_turn:
                            for part in model_turn.parts:
                                if hasattr(part, "inline_data") and part.inline_data:
                                    chunk = part.inline_data.data
                                    received_any_audio = True
                                    try:
                                        await websocket.send_bytes(chunk)
                                    except Exception as e:
                                        raise NoodleError(f"Failed to send audio to client: {repr(e)}")

                        if message.server_content.turn_complete:
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
            except NoodleError:
                raise
            except Exception as e:
                raise NoodleError(f"Unexpected error while getting Gemini response: {repr(e)}")

            if not received_any_audio:
                raise NoodleError("Noodle didn't generate any audio. Try speaking a bit lesser.")

            try:
                await websocket.send_text("__AUDIO_END__")
            except Exception:
                pass