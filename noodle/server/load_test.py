import asyncio
import time
import uuid
import argparse
import websockets

async def simulate_user(user_id, uri, metrics):
    """Simulates a single user connecting, sending dummy audio, and waiting for the response."""
    start_time = time.time()
    try:
        # Use a random device UUID for each user to bypass or test rate limiting correctly
        device_uuid = str(uuid.uuid4())
        full_uri = f"{uri}?device_uuid={device_uuid}"
        
        async with websockets.connect(full_uri) as websocket:
            # 1. Send actual audio data from the PCM file
            print("reading and sending actual audio data...")
            with open("Hello_Noodle.pcm", "rb") as f:
                audio_data = f.read()
            
            # Send the audio data in chunks to simulate streaming (or all at once)
            await websocket.send(audio_data)
            # 2. Send END to signal Noodle to process the audio
            await websocket.send("END")
            print("dummy data went")
            
            first_response_time = None
            print("waiting for response.")
            # 3. Wait for Noodle (and Gemini) to respond
            while True:
                response = await websocket.recv()
                
                if first_response_time is None:
                    first_response_time = time.time()
                
                if isinstance(response, str):
                    if response == "__AUDIO_END__":
                        break
                    else:
                        print(f"[User {user_id}] Server returned message: {response}")
                        metrics['failed'] += 1
                        return
                # print("end")   
        end_time = time.time()
        
        # Calculate metrics
        total_duration = end_time - start_time
        ttfb = first_response_time - start_time if first_response_time else 0
        
        metrics['successful'] += 1
        metrics['total_durations'].append(total_duration)
        metrics['ttfb_durations'].append(ttfb)
        
        print(f"[User {user_id}] Success | TTFB: {ttfb:.2f}s | Total: {total_duration:.2f}s")
        
    except Exception as e:
        print(f"[User {user_id}] Failed: {e}")
        metrics['failed'] += 1

async def run_load_test(num_users, uri):
    print(f"Starting load test with {num_users} concurrent users on {uri}...")
    
    metrics = {
        'successful': 0,
        'failed': 0,
        'total_durations': [],
        'ttfb_durations': []
    }
    
    start_time = time.time()
    
    # Spawn concurrent user tasks
    tasks = [simulate_user(i, uri, metrics) for i in range(num_users)]
    await asyncio.gather(*tasks)
    
    end_time = time.time()
    
    print("\n" + "="*40)
    print("--- Load Test Results ---")
    print("="*40)
    print(f"Total Concurrent Users: {num_users}")
    print(f"Total Test Duration:    {end_time - start_time:.2f}s")
    print(f"Successful Requests:    {metrics['successful']}")
    print(f"Failed Requests:        {metrics['failed']}")
    
    if metrics['successful'] > 0:
        avg_total = sum(metrics['total_durations']) / len(metrics['total_durations'])
        avg_ttfb = sum(metrics['ttfb_durations']) / len(metrics['ttfb_durations'])
        print(f"Average Time to First Byte (TTFB): {avg_ttfb:.2f}s")
        print(f"Average Total Request Duration:    {avg_total:.2f}s")
    print("="*40)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Load test Noodle WebSocket Server")
    parser.add_argument("-u", "--users", type=int, default=10, help="Number of concurrent users")
    parser.add_argument("--url", type=str, default="wss://maitry4-noodle-backend.hf.space/ws/noodle", help="WebSocket URI")
    
    args = parser.parse_args()
    
    try:
        asyncio.run(run_load_test(args.users, args.url))
    except KeyboardInterrupt:
        print("\nLoad test interrupted.")
