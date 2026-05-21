# FitVerse v1 Design Spec

## Overview

Fitness social app with AI coach, daily check-ins, and goal tracking. Target: Gym-goers aged 18-35.

---

## App Flow

1. **Splash Screen** - SX logo, 1-2 sec, check auth state
2. **Onboarding** (if not logged in) - Multi-step signup
3. **Main App** - 4 tabs, profile dropdown
4. **Stay logged in** - Keychain persistence

---

## Onboarding Flow

**Step 1:** Name, Email, Password
**Step 2:** Home Gym (location picker, for future gym buddy feature)
**Step 3:** Height, Weight, Gender
**Step 4:** Fitness Goal (build muscle, lose weight, maintain, etc.)
**Step 5:** Injuries/Limitations (optional)

Gender selection affects app theme (colors).

---

## Tab Structure

### Tab 1: Social (Curated Feed)
- Scrollable feed of gym content
- Placeholder posts for v1
- Designed for future TikTok API integration
- TikTok-style vertical scrolling

### Tab 2: Friends (Daily Check-ins)
- BeReal-style photo-only posts
- See mutual friends' check-ins
- Camera button to post your gym photo
- Timeline of gym photos from people you follow
- No captions, just photos

### Tab 3: AI Coach
- Chat interface (user types, gets responses)
- Conversations can influence/update workout plans
- User constraints stored (injuries, preferences, goals)
- Mock responses initially, real AI API later
- Daily workout cards displayed

### Tab 4: Goals
- Default metrics: Weight, Streak (consecutive days)
- User can add: Calories, body measurements, PRs, etc.
- Progress charts/visuals
- Customizable dashboard (add/remove metrics)

---

## Profile Dropdown

Top-right gear icon (Instagram-style) with:
- Settings
- Edit Profile
- Privacy
- Legal
- Logout

---

## Gender-Based Theming

Base theme: Blue/purple gradient from SX logo

| Gender | Theme Variation |
|--------|-----------------|
| Male | More blue/grey tones, bolder accent |
| Female | More purple tones, softer accent |

Same layout/structure for both, only color palette differs.

---

## Data Models

### User
```
- id: UUID
- name: String
- email: String
- passwordHash: String
- homeGym: String (location)
- height: Double
- weight: Double
- gender: Enum (male, female, other)
- fitnessGoal: Enum (buildMuscle, loseWeight, maintain, generalFitness)
- injuries: [String]
- isPremium: Bool
- aiUsageCount: Int (for subscription limiting)
- createdAt: Date
```

### Workout
```
- id: UUID
- userId: UUID
- date: Date
- exercises: [Exercise]
- completed: Bool
- notes: String?
```

### Exercise
```
- id: String (from JSON)
- name: String
- category: String (strength, cardio, stretching)
- primaryMuscles: [String]
- secondaryMuscles: [String]
- equipment: String
- level: String (beginner, intermediate, advanced)
- description: String
- animationUrl: String? (GIF path)
```

### CheckIn
```
- id: UUID
- userId: UUID
- date: Date
- photoData: Data (local storage)
- gymLocation: String?
```

### Goal
```
- id: UUID
- userId: UUID
- type: Enum (weight, streak, calories, bodyFat, pr, custom)
- currentValue: Double
- targetValue: Double?
- unit: String
- history: [MetricEntry]
- isActive: Bool
```

### MetricEntry
```
- id: UUID
- goalId: UUID
- value: Double
- date: Date
- notes: String?
```

### ChatMessage
```
- id: UUID
- userId: UUID
- content: String
- isFromUser: Bool
- timestamp: Date
```

---

## Service Layer

Services are protocol-based for easy mocking and future API integration.

### AuthService
- `signIn(email, password)` -> User
- `signUp(name, email, password)` -> User
- `signOut()` -> Void
- `isAuthenticated()` -> Bool
- `getCurrentUser()` -> User?

### UserService
- `getUser(id)` -> User
- `updateUser(user)` -> User
- `updateWeight(userId, weight)` -> Void

### WorkoutService
- `getWorkouts(userId)` -> [Workout]
- `getTodaysWorkout(userId)` -> Workout?
- `generateWorkout(userId, constraints)` -> Workout
- `updateWorkout(workout)` -> Workout
- `markComplete(workoutId)` -> Void

### SocialService
- `getFeed()` -> [SocialPost] (placeholder)
- Future: TikTok API integration

### AIService
- `sendMessage(message, context)` -> String (mock responses)
- `updateWorkoutFromChat(userId, conversation)` -> Workout?
- Future: Claude/GPT API integration

### GoalService
- `getGoals(userId)` -> [Goal]
- `addGoal(userId, type)` -> Goal
- `updateMetric(goalId, value)` -> Void
- `removeGoal(goalId)` -> Void

### SubscriptionService
- `isPremium(userId)` -> Bool
- `getAiUsageCount(userId)` -> Int
- `incrementAiUsage(userId)` -> Void
- `canUseAi(userId)` -> Bool (checks limits)

---

## Technical Stack

| Component | Technology |
|-----------|------------|
| UI | SwiftUI, iOS 17+ |
| Local Data | SwiftData |
| Networking | URLSession + async/await |
| Authentication | Local (Keychain) |
| Architecture | MVVM with Services |
| AI | Mock now, Claude/GPT API later |
| Subscription | RevenueCat or native IAP later |

---

## File Structure

```
FitVerse/
├── App/
│   ├── FitVerseApp.swift
│   └── AppDelegate.swift
├── Models/
│   ├── User.swift
│   ├── Workout.swift
│   ├── Exercise.swift
│   ├── CheckIn.swift
│   ├── Goal.swift
│   └── ChatMessage.swift
├── ViewModels/
│   ├── OnboardingViewModel.swift
│   ├── SocialViewModel.swift
│   ├── FriendsViewModel.swift
│   ├── CoachViewModel.swift
│   └── GoalsViewModel.swift
├── Views/
│   ├── Splash/
│   │   └── SplashView.swift
│   ├── Onboarding/
│   │   ├── OnboardingContainerView.swift
│   │   ├── NameEmailView.swift
│   │   ├── HomeGymView.swift
│   │   ├── PhysicalInfoView.swift
│   │   ├── FitnessGoalView.swift
│   │   └── InjuriesView.swift
│   ├── Social/
│   │   └── SocialView.swift
│   ├── Friends/
│   │   ├── FriendsView.swift
│   │   └── CheckInView.swift
│   ├── Coach/
│   │   ├── CoachView.swift
│   │   └── ChatView.swift
│   ├── Goals/
│   │   ├── GoalsView.swift
│   │   └── AddGoalView.swift
│   ├── Profile/
│   │   └── ProfileMenuView.swift
│   ├── MainTabView.swift
│   └── Components/
│       ├── TabBar.swift
│       ├── GoalCard.swift
│       ├── WorkoutCard.swift
│       └── CheckInCard.swift
├── Services/
│   ├── Protocols/
│   │   └── ServiceProtocols.swift
│   ├── Mock/
│   │   ├── MockAuthService.swift
│   │   ├── MockUserService.swift
│   │   ├── MockWorkoutService.swift
│   │   ├── MockSocialService.swift
│   │   ├── MockAIService.swift
│   │   ├── MockGoalService.swift
│   │   └── MockSubscriptionService.swift
│   └── DI/
│       └── ServiceContainer.swift
├── Resources/
│   ├── custom_exercises.json
│   ├── animations/
│   ├── static/
│   │   ├── SX.PNG
│   │   └── gifs/
│   └── Assets.xcassets/
├── Extensions/
│   ├── Theme.swift
│   ├── Color+Theme.swift
│   └── Data+Formatting.swift
└── Utils/
    └── FormValidator.swift
```

---

## Existing Assets

- 876 exercises in `custom_exercises.json`
- 57 workout animation GIFs in `Resources/static/gifs/`
- Logo: `SX.PNG` (blue/purple gradient)

---

## Future Considerations

1. **Backend API** - Replace mock services with real API calls
2. **AI Integration** - Connect to Claude or GPT API for coach
3. **Subscription** - RevenueCat or native IAP for premium features
4. **Social Integration** - TikTok API for curated content
5. **Gym Buddy** - Location-based friend matching using home gym
6. **Cloud Sync** - CloudKit or custom backend for multi-device
