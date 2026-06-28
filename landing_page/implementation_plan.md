# Redesign Landing Page to Match Cutesy Vibe

We will redesign the landing page to have a warm, cute aesthetic that matches your Noodle app, removing the stark dark overlays and making it a seamless single-page experience with two beautiful phases.

## Proposed Changes

### 1. Two-Phase Flow & Animation
Instead of a separate dark overlay component, we will build a single immersive experience built on top of the native background video.

**Phase 1 (Intro):**
- Full-screen video background playing normally (no `bg-black/70` mask).
- Center text: "Get me out of my head."
- Button: "Get me out of my head."

**The Animation:**
- When clicking the button, we trigger a fun, immersive animation (e.g., the intro text and button zoom forward and blur out as if you are moving *through* them, simulating getting out of your head).

**Phase 2 (Hero):**
- The hero UI components smoothly fade/slide in on top of the same video background.
- This includes the main title, the "Download Now" button, the "Rants resolved" metric, and the floating "Complain" button.

### 2. Global Styles & Layout
Update the fonts and base styling to match the warm, playful vibe.

#### [MODIFY] [globals.css](file:///e:/Noodle/landing_page/src/app/globals.css)
- Import a cute, playful font from Google Fonts, such as `Quicksand` or `Fredoka`.
- Remove stark black and white variables; replace them with warm cream and soft dark brown text.

#### [MODIFY] [layout.tsx](file:///e:/Noodle/landing_page/src/app/layout.tsx)
- Apply the new font and maintain `h-full` to prevent scrolling.

### 3. Page Components

#### [MODIFY] [page.tsx](file:///e:/Noodle/landing_page/src/app/page.tsx)
- This file will act as the master controller for the two phases, holding the background video natively and managing the animation state.
- Ensure strict `h-screen` and `overflow-hidden`.

#### [DELETE] [IntroOverlay.tsx](file:///e:/Noodle/landing_page/src/components/IntroOverlay.tsx) & [SocialProof.tsx](file:///e:/Noodle/landing_page/src/components/SocialProof.tsx)
- We are merging their responsibilities into the main `page.tsx` and `Hero.tsx`.

#### [MODIFY] [Hero.tsx](file:///e:/Noodle/landing_page/src/components/Hero.tsx)
- Render the main title, "Download" button, and integrate the "Rants resolved" metric (247,481).
- Style text to be playful (e.g., using soft brown and cute typography).

#### [MODIFY] [FloatingComplaint.tsx](file:///e:/Noodle/landing_page/src/components/FloatingComplaint.tsx)
- Update the floating button to use soft rounded edges and cute colors (e.g., olive green or soft orange from your image), ensuring it only appears in Phase 2.

## Verification Plan

### Manual Verification
- We will start the local Next.js dev server.
- Verify Phase 1 loads natively over the video.
- Click the intro button and verify the transition animation feels like "getting out of your head".
- Verify Phase 2 displays the hero elements, floating complain button, and rants resolved without requiring any scrolling.
