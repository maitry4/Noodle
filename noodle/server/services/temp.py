import asyncio
import inspect
import os
from dotenv import load_dotenv
from google import genai
from google.genai import types

load_dotenv()

client = genai.Client(api_key=os.getenv("API_KEY"))

async def main():
    async with client.aio.live.connect(
        model="gemini-2.5-flash-native-audio-latest"
    ) as session:
        print("send:")
        print(inspect.signature(session.send))

        print("\nsend_realtime_input:")
        print(inspect.signature(session.send_realtime_input))

        print("\nsend_client_content:")
        print(inspect.signature(session.send_client_content))

        print("\nreceive:")
        print(inspect.signature(session.receive))
        print("\nblob")
        print(inspect.signature(types.Blob))
        print(types.Blob)

asyncio.run(main())