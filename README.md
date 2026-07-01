# 🍜 Noodle

> A sarcastic voice companion that helps you stop overthinking, one emotional dump at a time.

🌐 **Download Now From:** [maitry4.github.io/Noodle](https://maitry4.github.io/Noodle/)

Noodle is a privacy-first AI companion designed for people who get stuck in loops of self-doubt, over-analysis, and overthinking.

Instead of maintaining long-term memory or conversation history, Noodle listens to what's bothering you **right now**, responds with a mix of humor and perspective, and then forgets everything.

No journaling.

No emotional archives.

No permanent storage.

Just vent, laugh, and move on.

---

## 📸 Screenshots

### Onboarding Experience

| Screen 1 | Screen 2 |
|----------|----------|
| ![](UI_Designs/onboarding_screen1.png) | ![](UI_Designs/onboarding_screen2.png) |

| Screen 3 | Screen 4 |
|----------|----------|
| ![](UI_Designs/onboarding_screen3.png) | ![](UI_Designs/onboarding_screen4.png) |

---

## ✨ Vision

Most AI assistants try to remember more about you over time.

Noodle does the opposite.

Its goal is not to become your second brain.

Its goal is to help you get out of your own head.

---

## 🎯 Core Principles

### Privacy First

Noodle never stores emotional dumps permanently.

User input exists only long enough to:

1. Transcribe speech
2. Generate a response
3. Deliver the response

After that, it is discarded.

---

### Lightweight Interaction

No chat threads.

No message history.

No conversation management.

Just:

```text
Press
↓
Rant
↓
Laugh
↓
Continue your day
```

---

### Friendly Sarcasm

Noodle isn't a therapist.

Noodle isn't a life coach.

Noodle is a slightly chaotic friend that occasionally points out when your brain is being ridiculous.

---

## 📱 User Flow

```text
[Choose your preferred language (English/Indian English (try it the most so far)/Hindi)]
Tap Noodle
↓
Speak your thoughts
↓
Speech → Text
↓
AI Processing
↓
Receive sarcastic response (Text-to-Speech playback)
↓
Everything is forgotten
```

---

## 🚀 Getting Started (Local Development)

### Prerequisites
* Flutter SDK (for the frontend app)
* Python 3.13+ (for the FastAPI backend — matches the deployed Docker image)
* Node.js (for the landing page)
* Gemini API Key
* Docker (optional, for running the backend the same way it's deployed)

### Backend Setup

**Option A — Local (no Docker)**
1. Navigate to the server directory: `cd noodle/server`
2. Install dependencies: `pip install -r requirements.txt`
3. Create a `.env` file with your API key:
   ```env
   API_KEY=your_gemini_api_key_here
   ```
4. Run the development server: `uvicorn main:app --reload`

**Option B — Docker (matches production deployment)**
1. Navigate to the server directory: `cd noodle/server`
2. Build the image:
   ```bash
   docker build -t noodle-backend .
   ```
3. Run the container:
   ```bash
   docker run -p 7860:7860 --env-file .env noodle-backend
   ```
4. The API will be available at `http://localhost:7860`

### Frontend Setup
1. Navigate to the app directory: `cd noodle`
2. Fetch dependencies: `flutter pub get`
3. Run the app: `flutter run`

---

## 🏗 Architecture

### Repository Structure

```text
Noodle/
│
├── noodle/
│   ├── lib/
│   ├── android/
│   ├── server/
│   │   ├── main.py
│   │   ├── services/
│   │   └── ...
│   └── ...
│
├── landing_page/
│   ├── src/
│   ├── package.json
│   └── next.config.ts
│
└── README.md
```

### Frontend

Built with Flutter using a lightweight feature-based architecture.

**Technologies**

* Flutter
* Riverpod
* GoRouter
* Hive
* Local Device Storage

**Features**

* Onboarding flow
* Immersive In-App Noodle companion (dynamic UI & cute interactions)
* Settings management
* Bring-your-own-key support
* Audio recording and playback

---

### Backend

Built with FastAPI and designed to remain stateless wherever possible.

**Technologies**

* FastAPI
* Gemini API
* REST API
* Rate Limiting
* Temporary Audio Processing

**Services**

* Request validation
* Usage limit checks
* Audio processing
* Response generation
* Statistics tracking

---

## 🌐 Deployment

### Landing Page

The public website is built with Next.js and hosted separately from the application backend.

```text
GitHub Pages
        │
        ▼
Landing Page (Static Export)
```

### Backend API

```text
FastAPI (Dockerized)
        │
        ▼
Hugging Face Spaces (Docker)
```

### Mobile App

```text
Flutter APK
        │
        ▼
Gumroad Distribution
```

This separation keeps infrastructure simple, inexpensive, and easy to scale independently.

> **Note:** Since the APK is distributed outside the Google Play Store, users will need to enable **"Install from unknown sources"** on their Android device. Android may also show a Play Protect warning on install — this is expected for apps not distributed via the Play Store.

---

## 📊 Public Statistics

Noodle exposes a lightweight public endpoint that powers the landing page statistics.

Examples:

* Total rants resolved
* Requests processed

No personal user information is included in these metrics.

---

## 🔒 Privacy Model

### Stored Locally

* Onboarding status
* User preferences
* Optional Gemini API key [Secured]
* Device identifier

### Temporarily Processed [Never Stored]

* Voice recordings
* Speech transcripts

These exist only long enough to generate a response and are automatically discarded.

### Never Stored

* Conversation history
* Emotional dumps
* User profiles
* Long-term memories
* Personal journals

Noodle is intentionally designed without persistent memory.

---

## 🧠 Bring Your Own Key (BYOK)

Users may provide their own Gemini API key.

Benefits:

- Higher usage limits
- Reduced dependency on shared infrastructure
- Faster access during high traffic periods

Users can also use the shared Noodle key, subject to rate limits (selectable from Settings).

---

## ❌ What Noodle Is Not

- A therapist
- A mental health diagnosis tool
- A journaling platform
- A productivity coach
- A memory assistant

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).
