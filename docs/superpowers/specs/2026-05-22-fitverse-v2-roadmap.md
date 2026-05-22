# FitVerse V2 Roadmap & Legal Requirements

**Date:** 2026-05-22
**Status:** Planning
**Author:** Michael Bell

---

## Overview

FitVerse V1 established the complete app skeleton: MVVM architecture, all 4 tabs, onboarding, SwiftData persistence, mock service layer, and 876 exercises with GIF assets. V2 replaces every mock service with real infrastructure, integrates the AI coach, launches the social graph, and satisfies all App Store and legal obligations required before public distribution.

---

## Pre-Launch Fixes (Already Implemented in This Commit)

These were addressed in the codebase before V2 work begins:

- [x] `FormValidator` — real email regex + password strength validation
- [x] Password security — SHA256 + salt (replacing base64 encoding)
- [x] Sign-in password verification — hash comparison on login
- [x] Double user creation bug — `OnboardingViewModel` now delegates fully to `authService.signUp`
- [x] Age gate — `birthYear` field added, 13+ validation in onboarding
- [x] Exercise name display — `CoachView` now shows exercise name instead of raw ID
- [x] Subscription usage — persisted via `User.aiUsageCount` in SwiftData
- [x] `DispatchQueue.main.asyncAfter` → `async/await` in `FitVerseApp`
- [x] `GoalCard` progress bar — normalized bar heights + fixed `Color.hex()` compile error
- [x] `MessageBubble` — AI message text now uses a distinct color from user messages

---

## V2 Feature Roadmap

### Phase 1 — Backend Foundation (Required for Everything Else)

#### 1.1 Backend API

Replace all mock services with a real server. Recommended stack: **Supabase** (PostgreSQL + Auth + Storage + Realtime) for a solo developer — avoids managing infrastructure while providing all needed capabilities.

**What to build:**
- User auth (email/password via Supabase Auth, or Firebase Auth)
- User profile storage and updates
- Workout storage and retrieval
- Goals and metric history storage
- Check-in storage with photo upload to object storage (Supabase Storage / S3)

**SwiftUI implementation:**
- Replace `MockAuthService` → `SupabaseAuthService`
- Replace `MockUserService` → `SupabaseUserService`
- Replace `MockWorkoutService` → `SupabaseWorkoutService`
- Replace `MockGoalService` → `SupabaseGoalService`
- All replacements slot in via the existing `ServiceContainer` with no View changes required

#### 1.2 SwiftData File Protection

Update `ModelConfiguration` to use `.fileProtection(.complete)` once a real backend is in place and sensitive data can be validated server-side. For health data (weight, injuries, height), encrypt at the field level before storage.

#### 1.3 SSL Certificate Pinning

Add certificate pinning to `URLSession` before the app handles real user data. Use `URLSessionDelegate` with `SecTrustEvaluateFast` or a library like TrustKit.

---

### Phase 2 — AI Coach (Real Integration)

Replace `MockAIService` with a real Claude API (or GPT) integration.

**Implementation:**
```
Services/Live/ClaudeAIService.swift
```

Key design decisions:
- **System prompt** should encode user context: fitness goal, injuries, recent workouts, current streak. Pass this as a cached system prompt to minimize tokens.
- **Conversation context** should be trimmed to last N messages to stay within context limits.
- **Workout modification** — when the AI suggests a workout change, parse structured JSON from the response and apply it via `WorkoutService.updateWorkout()`.
- **Rate limiting** — existing `SubscriptionService.canUseAi()` pattern is correct; wire it to the real `User.aiUsageCount` field (already done in pre-launch fixes).

**Subscription tiers:**
- Free: 10 AI messages/day (already modeled)
- Premium: Unlimited messages + personalized weekly plans

---

### Phase 3 — Social Graph

#### 3.1 Friends System

Currently the Friends tab shows only the current user's check-ins. V2 needs:
- User search (by name or username)
- Follow/unfollow
- Feed of followed users' check-ins
- Friend request flow (optional — could start with open follow model)

**Backend:** `follows` table with `follower_id` and `following_id`. Feed query fetches check-ins from all followed users ordered by `date DESC`.

#### 3.2 Real Gym Location Verification

Replace the static `GymLocation.mockGyms()` list with:
1. **Foursquare Places API** or **Google Places API** — search for gyms near the user's current location
2. **Location permission** — `CLLocationManager` with `requestWhenInUseAuthorization()`
3. Verify check-in by comparing device GPS to selected gym coordinates (within ~200m radius)

#### 3.3 Check-in Photo Storage

Move `CheckIn.photoData` from raw bytes in SwiftData to:
1. Upload photo to Supabase Storage / S3 on check-in post
2. Store only the URL in SwiftData
3. Load images lazily with `AsyncImage` in `CheckInCard`

This eliminates the unencrypted photo blob in the local database.

---

### Phase 4 — Social Content Feed

The Social tab is currently static placeholder posts. Two options:

**Option A — Curated In-House Content (Recommended for V1 launch)**
- Create a `content` table in the backend with fitness tips, form guides, nutrition posts authored by FitVerse
- No third-party API dependency, full control, zero regulatory risk
- Can evolve to UGC later

**Option B — TikTok API Integration**
- Curated fitness content from TikTok via Display API
- Risk: US regulatory status of TikTok is actively uncertain (potential forced sale/ban). App could break with no notice.
- Recommendation: Build Option A first, add TikTok as an optional enhancement behind a feature flag

---

### Phase 5 — Monetization

**RevenueCat** for subscription management (handles receipt validation, renewal, cancellation, and analytics across iOS).

Subscription tiers:
- **Free:** Core workout tracking, goal tracking, 10 AI messages/day
- **Premium ($9.99/mo or $79.99/yr):** Unlimited AI coaching, personalized weekly plans, advanced progress charts

App Store requirements for subscriptions:
- Auto-renewable subscriptions require a "Subscription" section in the App Store listing
- Free trial terms must be disclosed in the listing and the app UI
- Cancellation must be reachable via Settings → Apple ID → Subscriptions (iOS handles this automatically)
- Apple takes 15% after year 1 of a subscription, 30% otherwise

---

### Phase 6 — Active Workout Screen

The most critical missing feature for daily engagement: a live workout session UI.

**Required screens:**
- `WorkoutSessionView` — shows exercises one at a time, timer between sets, rest timer
- `ExerciseDetailView` — name, GIF animation, sets/reps/weight logging per set
- `WorkoutCompleteView` — summary, total volume, personal records

**Data changes:**
- `WorkoutExercise` needs per-set logging: `sets: [SetLog]` where `SetLog` has `reps`, `weight`, `completed`
- `Workout.completed` already exists; populate it from `WorkoutSessionView` on finish

---

### Phase 7 — Exercise Browser

876 exercises are in `custom_exercises.json` but not browsable. Add:
- `ExerciseLibraryView` — searchable, filterable by muscle group and equipment
- `ExerciseDetailView` — name, description, GIF, primary/secondary muscles, difficulty
- Can be surfaced from the AI coach ("show me how to do a Romanian Deadlift")

---

### Phase 8 — Apple Health Integration

Post-launch enhancement:
- Sync completed workouts to Apple Health as `HKWorkout`
- Read steps, active calories, sleep data to surface in Goals tab
- **Note:** HealthKit data cannot be used for advertising or shared with third parties. Apple enforces this during review.

---

## Legal Requirements

### Required Before App Store Submission

#### Privacy Policy
A publicly accessible Privacy Policy URL is **mandatory** — Apple blocks submission without one.

Minimum required content:
- What data is collected (name, email, height, weight, fitness goals, injuries, location, photos, chat messages)
- Why it is collected and how it is used
- Whether data is shared with third parties (future: Claude/GPT API, RevenueCat, Google/Foursquare Places)
- How users can request data deletion
- Contact information for privacy requests

Recommended: Use a generator like Termly or iubenda for the initial version, then have a lawyer review before significant user scale.

#### Terms of Service
Required before users can create accounts. Covers:
- Acceptable use
- Age restrictions (13+ minimum)
- User-generated content (check-in photos)
- No medical advice disclaimer (AI coach is for fitness guidance only, not medical diagnosis)
- Liability limitations

#### App Privacy Nutrition Label (App Store Connect)
Must declare every data type collected before submission. Based on the current app:

| Data Type | Collected | Purpose | Linked to Identity |
|---|---|---|---|
| Name | Yes | Account | Yes |
| Email | Yes | Account | Yes |
| Height / Weight | Yes | Personalization | Yes |
| Fitness Goal | Yes | Personalization | Yes |
| Injuries | Yes | Personalization | Yes |
| Location | Yes | Gym check-in | Yes |
| Photos | Yes | Check-ins | Yes |
| Chat messages (AI) | Yes | AI coaching | Yes |
| Workout history | Yes | Progress tracking | Yes |

#### Info.plist Permission Strings (Add in Xcode)
These must be added in Xcode under Target → Info before the app can request system permissions:

```
NSPhotoLibraryUsageDescription
"FitVerse uses your photo library to add gym check-in photos to your posts."

NSLocationWhenInUseUsageDescription
"FitVerse uses your location to verify you're at the gym when checking in."

NSCameraUsageDescription
"FitVerse uses your camera to take gym check-in photos."

NSHealthShareUsageDescription  (when HealthKit is added)
"FitVerse reads your activity data to surface it in your Goals dashboard."

NSHealthUpdateUsageDescription  (when HealthKit is added)
"FitVerse saves your completed workouts to Apple Health."
```

---

### U.S. Legal Requirements

#### COPPA (Children's Online Privacy Protection Act)
- Users under 13 cannot use apps that collect personal data without verifiable parental consent
- **Status:** Age gate (13+) added to onboarding in pre-launch fixes
- **Action:** Add explicit age check before account creation; do not allow users born after `currentYear - 13`

#### HIPAA
- Consumer fitness tracking apps are **not** covered entities and do not fall under HIPAA
- FitVerse is in the clear as long as it does not establish a relationship with a healthcare provider
- If HealthKit is added, data must not be shared with advertisers or used for non-health purposes (Apple enforces this contractually)

#### CCPA (California Consumer Privacy Act)
- Users in California have the right to know what data is collected, request deletion, and opt out of sale
- **Action needed:** Implement account deletion (V2 Phase 1 backend work)
- Add "Delete My Account" option in the Profile/Settings menu

---

### International Requirements

#### GDPR (EU / UK)
Applies to any EU/UK user regardless of where the company is based.

**Required before EU launch:**
1. **Explicit consent** for processing health data (sensitive category under GDPR). The onboarding must have a clear consent checkbox for health data collection, separate from Terms of Service acceptance.
2. **Right to erasure** — users must be able to delete their account and all associated data. Implement in V2 Phase 1.
3. **Data portability** — users should be able to export their data (workout history, goals, check-ins). Nice-to-have initially; required if scale grows.
4. **Privacy Policy** must name every third-party service that receives user data and their privacy policies.
5. **Data Processing Agreement** — required with any third-party processor (Supabase, Anthropic, RevenueCat, etc.) before using their services with EU user data.

---

### Third-Party Integration Obligations

#### Claude / GPT API (AI Coach)
- User messages (including health information) leave the device and are sent to Anthropic/OpenAI servers
- Must be disclosed in Privacy Policy
- Do not store AI responses beyond session context to build a proprietary training dataset (violates Anthropic ToS)
- Anthropic API: permitted for fitness/wellness use cases

#### RevenueCat
- Acts as a data processor for subscription and purchase data
- Requires DPA before EU user data is processed
- Do not share more user data than necessary (email + user ID is sufficient)

#### Google Places / Foursquare (Gym Verification)
- Google Places API requires attribution ("Powered by Google") in the UI near location results
- Both have rate limits; implement caching to stay within free tiers during early growth

---

## V2 Priority Order (Solo Developer)

Given solo development capacity, the recommended sequence:

1. **Backend + Auth** (Supabase) — unlocks everything else
2. **Privacy Policy + ToS + App Privacy Label** — required for submission
3. **Account deletion** — required for CCPA/GDPR
4. **Active Workout Screen** — highest user value, daily engagement driver
5. **Real AI integration** — core differentiator
6. **Exercise browser** — complements workout screen
7. **Social graph** (follows + real check-in feed) — growth driver
8. **Subscription / RevenueCat** — monetization
9. **Gym location verification** (real GPS + Places API)
10. **Social content feed** (in-house curated first, TikTok later)
11. **Apple Health sync** — post-launch enhancement
