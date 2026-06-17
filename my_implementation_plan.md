# FastAPI Server Implementation Plan

Simple, secure backend — **2 endpoints**, **3 service classes**, **Gemini Native Audio**.

---

## Dependencies

```bash
pip install python-multipart uvicorn google-genai
```

| Package | Why |
|---|---|
| `python-multipart` | FastAPI needs this for `UploadFile` (multipart form data) |
| `uvicorn` | Local dev server |
| `google-genai` | The unified Gemini SDK (replaces the old `google-generativeai`) |

---

## Device ID Strategy

**No verification needed.** The device ID exists purely as a rate-limit key.

| Side | What it does |
|---|---|
| **Flutter** | Generate a `UUID v4` on first launch → store in Hive → send as `X-Device-Id` header with every request |
| **Server** | Validate format (non-empty, ≤ 64 chars) → use as dictionary key for rate limiting. Done. |

> [!NOTE]
> If someone spoofs a device ID, they just get a fresh daily limit — that's acceptable for MVP. The real cost protection is that Gemini API calls still require a key (yours or theirs). You can always harden this later with device attestation if needed.

---

## Gemini Model

**Model**: `gemini-2.5-flash-native-audio-dialog`

This model accepts audio input natively and can return **both text and audio** in a single `generate_content` call.

We will use `system_instruction` to set Noodle's personality and rules.

```python
from google import genai
from google.genai import types

client = genai.Client(api_key=api_key)

SYSTEM_PROMPT = """You are Noodle.

Noodle is a sarcastic but kind voice companion.

Your job is NOT to roast the user.
Your job is to notice the funny, unrealistic conclusion their brain created from the situation and gently poke fun at that conclusion.

You are like a witty friend who says:
"Wait... your brain actually decided THAT was the ending?"

Process:
1. Read the rant carefully.
2. Find the moment where the user became 100% certain about a negative outcome.
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
- Do not make jokes about something the user is genuinely grieving.
- Avoid sounding like you know the future.

Sensitive topics:
If the rant involves loneliness, relationships, friendships, rejection, appearance, self-worth, or insecurity:
- Be gentler.
- Make fun of the prediction, not the fear.
- Do not make the user feel embarrassed for caring.

Avoid these words:
- leap
- massive leap
- Olympic leap
- worst-case scenario
- catastrophic thinking

Do not say:
"Your reasoning is..."
"You're doing..."
"This is because..."

Instead, react like a friend noticing the brain's dramatic conclusion.
If the user speaks in Hinglish or Hindi, respond back in the same style."""

response = client.models.generate_content(
    model="gemini-2.5-flash-native-audio-dialog",
    contents=[
        types.Part.from_bytes(data=audio_bytes, mime_type="audio/m4a"),
    ],
    config=types.GenerateContentConfig(
        system_instruction=SYSTEM_PROMPT,
        response_modalities=["AUDIO", "TEXT"],
        speech_config=types.SpeechConfig(
            voice_config=types.VoiceConfig(
                prebuilt_voice_config=types.PrebuiltVoiceConfig(voice_name="Kore")
            )
        ),
    ),
)
```

---

## File Structure (After)

```
server/
├── main.py                          # [MODIFY] FastAPI app + 2 endpoints
├── services/
│   ├── __init__.py                  # [NEW] Package init
│   ├── noodle_service.py            # [NEW] Gemini native audio call
│   ├── rate_limiter.py              # [NEW] Per-device daily rate limiting
│   └── stats_service.py             # [NEW] Rant counter for landing page
└── data/
    ├── visit_stats.json             # [EXISTING] Will be initialized properly
    └── temporary_audio/             # [EXISTING] (kept for any future use)
```

**Old stubs to delete** (replaced by the 3 new files):
- `services/check_limit.py`
- `services/get_roast.py`
- `services/request_counter.py`
- `services/respond_user.py`
- `services/save_audio_temporarily.py`

---

## Proposed Changes

### [MODIFY] [main.py](file:///e:/Noodle/server/main.py)

Two endpoints + CORS middleware:

#### `POST /noodle`

```
Headers:  X-Device-Id (required, UUID format)
Body:     multipart form — audio file + optional api_key field

Flow:
  1. Validate X-Device-Id (non-empty, ≤64 chars)
  2. Validate audio file (exists, ≤10MB, audio MIME type)
  3. Determine API key: use provided api_key, else fall back to server's NOODLE_API_KEY env var
  4. If using shared key → check rate limit → 429 if exceeded
  5. Call NoodleService.process(audio_bytes, api_key)
  6. Increment stats counter
  7. Return JSON: { "text": "...", "audio_b64": "..." }

Error responses:
  - 400: Missing/invalid device ID, missing audio
  - 413: Audio file too large
  - 429: Rate limit exceeded
  - 500: Gemini API error (may occur mostly for user providing invalid api key.)
```

#### `GET /stats`

```
No auth required.
Returns: { "rants_resolved": N }
```

#### CORS

```python
origins = [
    "http://localhost:3000",     # Landing page dev
    "http://localhost:8000",     # Local testing
]
# Will add production GitHub Pages domain before deploy
```

---

### [NEW] [noodle_service.py](file:///e:/Noodle/server/services/noodle_service.py)

```python
class NoodleService:
    def process(self, audio_bytes: bytes, api_key: str) -> dict:
        """
        Sends audio to Gemini 2.5 Flash Native Audio Dialog.
        Returns { "text": str, "audio_b64": str | None }
        """
        # 1. Create genai client with the provided key
        # 2. Call generate_content with audio bytes + system_instruction
        # 3. Extract text and audio from response
        # 4. Base64-encode the audio for JSON transport
        # 5. Return both
```

---

### [NEW] [rate_limiter.py](file:///e:/Noodle/server/services/rate_limiter.py)

```python
class RateLimiter:
    """In-memory per-device daily rate limiter."""
    # there should be a rate_limit.json too. So that the rate limit persist even if the server restarts.
    # or we can have a small redis db with 24 hrs ttl on the count reset device-id every 24 hours back to 0.
    MAX_DAILY_REQUESTS = 10

    def __init__(self):
        self._usage: dict[str, dict] = {}
        # Format: { "device-id": { "count": 5, "date": "2026-06-16" } }

    def is_allowed(self, device_id: str) -> bool:
        """Check if device is under daily limit. Auto-resets on new day."""

    def increment(self, device_id: str) -> None:
        """Bump usage count for today."""
```

---

### [NEW] [stats_service.py](file:///e:/Noodle/server/services/stats_service.py)

```python
class StatsService:
    """Reads/writes rant count to data/visit_stats.json."""

    def __init__(self, data_path: str = "data/visit_stats.json"):
        ...

    def get_stats(self) -> dict:
        """Returns { "rants_resolved": N }"""

    def increment(self) -> None:
        """Atomically increments the rant counter."""
```

---

### [NEW] [\_\_init\_\_.py](file:///e:/Noodle/server/services/__init__.py)

Empty file — makes `services/` a proper Python package for clean imports.

---

## Security Summary

| Measure | Implementation |
|---|---|
| **Device ID** | UUID from Flutter, format-validated on server, used only as rate-limit key |
| **Rate limiting** | 10/day per device on shared key; BYOK users skip limits |
| **File size** | Reject audio > 10MB |
| **CORS** | Restricted origins (dev + production domain) |
| **No storage** | Audio bytes exist only in memory during the request, never written to disk |
| **API key** | Server's shared key via `NOODLE_API_KEY` env var; never exposed to client |
