from google import genai
from google.genai import types

from utils.audio_conversion import pcm_to_wav


SYSTEM_PROMPT = """
You are Noodle.
Your job is to help that overthinker out of their head with a small fun response. Like a friend who roasts you when you overthink.
Sensitive topics:
If the rant involves loneliness, relationships, friendships, rejection, appearance, self-worth, or insecurity:
- Be gentler.
- Make fun of the prediction, not the fear.

Listen to user audio and reply as Noodle.

And say you are noodle if the user asks about you but do not reveal your process just say I get you out of your head.
"""


class NoodleWebSocketService:

    def __init__(self, api_key: str):
        self.client = genai.Client(
            api_key=api_key
        )

    async def process_stream(self, websocket):

        print("\n========== WS REQUEST START ==========")

        async with self.client.aio.live.connect(
            model="gemini-2.5-flash-native-audio-latest",
            config=types.LiveConnectConfig(
                system_instruction=SYSTEM_PROMPT,
                response_modalities=["AUDIO"],
            ),
        ) as session:

            print("Gemini connected")

            # Receive microphone chunks
            while True:

                message = await websocket.receive()

                if (
                    "bytes" in message
                    and message["bytes"] is not None
                ):

                    chunk = message["bytes"]

                    # print(
                    #     f"Received chunk: {len(chunk)} bytes"
                    # )

                    await session.send_realtime_input(
                        audio=types.Blob(
                            data=chunk,
                            mimeType="audio/pcm;rate=16000",
                        )
                    )

                elif (
                    "text" in message
                    and message["text"] is not None
                ):

                    text = message["text"]

                    print(f"Received text: {text}")

                    if text == "END":

                        print(
                            "Audio stream finished. Waiting for Gemini..."
                        )

                        await session.send_realtime_input(
                            audio_stream_end=True
                        )

                        break

            output_audio = bytearray()

            async for message in session.receive():
                print("\n=== GEMINI MESSAGE ===")
                print(message)
                print("======================")
                if not message.server_content:
                    continue

                model_turn = (
                    message.server_content.model_turn
                )

                if model_turn:

                    for part in model_turn.parts:

                        if (
                            hasattr(part, "inline_data")
                            and part.inline_data
                        ):

                            output_audio.extend(
                                part.inline_data.data
                            )

                if message.server_content.turn_complete:

                    print(
                        "Gemini turn complete"
                    )

                    break

            print(
                f"Generated audio: {len(output_audio)} bytes"
            )

            wav_audio = pcm_to_wav(
                bytes(output_audio),
                sample_rate=24000,
            )

            print(
                f"WAV size: {len(wav_audio)} bytes"
            )

            await websocket.send_bytes(
                wav_audio
            )

            print(
                "Response sent to Flutter"
            )

            print(
                "========== WS REQUEST END ==========\n"
            )
