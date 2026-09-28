# PlayHub — iOS Game Hub

A SwiftUI arcade app featuring 3 mini-games with persistent stats, geotagging, and trivia API integration.

---

## Architecture: MVVM + SwiftUI

```
ios_dev_app/
├── PlayHubApp/
│   ├── App/
│   │   └── PlayHubApp.swift         # @main entry point, TabView root
│   │
│   ├── Models/
│   │   ├── GameMode.swift           # Enum: .tapFrenzy, .lightItUp, .quizRush
│   │   ├── GameSession.swift        # Codable session (mode, score, timestamp, lat/lng)
│   │   ├── StatusGame.swift         # ObservableObject — manages all sessions, persisted via UserDefaults
│   │   ├── LightItUp/
│   │   │   └── LightItUpModels.swift # LitCard, GameLevel (4 levels with scaling difficulty)
│   │   └── QuizRush/
│   │       ├── TriviaModels.swift    # Question, TriviaResponse (Codable)
│   │       ├── TriviaCategory.swift  # Category picker (maps to Open Trivia DB IDs)
│   │       └── QuizDifficulty.swift  # Easy / Medium / Hard — scoring multipliers
│   │
│   ├── ViewModels/
│   │   ├── TapFrenzyViewModel.swift  # Timer, tap count, shrinking button, position randomizer
│   │   ├── LightItUpViewModel.swift  # Grid lifecycle, lit-card cycling, lives, level progression
│   │   └── QuizRushViewModel.swift   # Quiz state machine, timer, scoring, streak logic
│   │
│   ├── Views/
│   │   ├── Tabs/
│   │   │   ├── home.swift            # Play tab — game selection cards
│   │   │   ├── StatsTab.swift        # Per-game overview, progress chart, history list
│   │   │   ├── MapTab.swift          # MapKit pins grouped by location, session detail sheets
│   │   │   └── SettingsTab.swift     # Daily notification toggle, per-game data reset
│   │   │
│   │   ├── Shared/
│   │   │   └── ResultsView.swift     # Generic game-over screen with ShareLink
│   │   │
│   │   └── Games/
│   │       ├── TapFrenzy/
│   │       │   └── TapFrenzyView.swift
│   │       ├── LightItUp/
│   │       │   └── LightItUpView.swift  # Intro → level selector → gameplay → popup result
│   │       └── QuizRush/
│   │           ├── QuizRushView.swift        # State-driven router (setup/loading/loaded/results)
│   │           ├── QuizSetupView.swift       # Category + difficulty stepper
│   │           ├── QuizQuestionView.swift    # Question card with answer buttons, timer, streaks
│   │           ├── QuizResultsView.swift     # Score reveal, confetti, share
│   │           └── Components/
│   │               ├── TimerRing.swift       # Circular countdown
│   │               ├── StreakBadge.swift     # Streak indicator
│   │               ├── ConfettiView.swift    # Particle animation
│   │               └── AnswerButton.swift    # Multi-state answer button
│   │
│   ├── Services/
│   │   ├── TriviaService.swift      # URLSession client for Open Trivia DB API
│   │   ├── NotificationService.swift# UNUserNotificationCenter — daily challenge reminders
│   │   └── LocationService.swift    # CLLocationManager — session geotagging
│   │
│   └── Extensions/
│       ├── StringHTMLDecode.swift   # HTML entity → plain text (trivia answers)
│       └── GamesSessionCoordinate.swift # CLLocationCoordinate2D computed on GameSession
```

---

## Navigation

- **Root**: `TabView` with 4 tabs (Play, Stats, Map, Settings)
- **Play** tab uses `NavigationStack` + `NavigationLink` to each game
- Each game manages its own internal navigation (setup → gameplay → results)

---

## The 3 Games

### 1. Tap Frenzy
A button shrinks and repositions after each tap. Score as many taps as possible in **10 seconds**. The button starts at 180pt and shrinks 6pt per tap (min 64pt).

### 2. Light It Up
Tap the lit card(s) before the cycle changes. **4 levels** with increasing grid size (3→4→6→9 cards), faster cycles (1.6s→0.85s), and unlock thresholds. 3 lives per level.

### 3. Quiz Rush
10 trivia questions from the [Open Trivia DB](https://opentdb.com). Choose a category + difficulty. Features a 15s per-question timer, streak bonuses (≥3 correct), and score penalties for wrong/timeout answers.

---

## Data Flow

```
View (SwiftUI)
  │  @StateObject / @ObservedObject
  ▼
ViewModel (ObservableObject)
  │  game logic, timers, scoring
  ▼
Model (struct / enum)
  │
  ├── Service Layer (TriviaService — async/await)
  └── Persistence Layer (StatusGame → UserDefaults)
```

- **StatusGame** (`ObservableObject`) is injected as an `@EnvironmentObject` at the app root
- Each game's ViewModel owns its transient state; results flow to `StatusGame` on game-over
- **LocationService** provides real-time coordinates appended to each saved session
- **UserDefaults** stores both session history (JSON-encoded `[GameSession]`) and per-game high scores

---

## Dependencies

- **SwiftUI** — all UI
- **MapKit** — session location map
- **CoreLocation** — user location
- **UserNotifications** — daily challenge reminders
- **Charts** (SwiftUI) — stats progress chart
- **Open Trivia DB** — trivia questions (external API)


---

## Features

- **Tab bar shell:** Play, Stats, Map and Settings tabs, dark theme.
- **Tap Frenzy:** 10-second reaction game with a shrinking, moving target.
- **Light It Up:** reflex grid game with 4 levels, 3 lives per level and a level progress bar.
- **Quiz Rush:** live trivia from the Open Trivia DB API, with category and difficulty selection, a per-question timer ring, streak bonuses, difficulty-based scoring and confetti on the results screen.
- **Stats (Swift Charts):** per-game overview cards, bar chart of recent scores and a history list.
- **Map of Games (MapKit + Core Location):** every finished game is geotagged. Sessions at the same place are grouped into one pin, with a detail sheet and a game-mode filter.
- **Daily Challenge notifications:** a repeating local notification at a time the user picks, controlled by a toggle and time picker in Settings.
- **Share Your Score:** `ShareLink` on the results screens.
- **Settings:** reset history for one game or clear everything, with a confirmation prompt.
- **Persistence:** sessions saved as JSON in `UserDefaults`; per-game high scores stored with `@AppStorage`.

---

## Known limitations

- **Storage:** `UserDefaults` re-encodes the whole session array on every save. This is fine at this scale, but Core Data or SwiftData would suit a larger history.
- **Quiz Rush needs internet.** There is no offline question bank, and the free Open Trivia DB API is rate limited, so quick repeated requests can fail.
- **Notifications:** the Daily Challenge is a reminder only and does not open a specific challenge. Scheduling replaces all pending notifications, so only one can be scheduled at a time.
- **Location:** map pins depend on location permission and a location fix.
- **Deployment target is iOS 26.2**, so it needs a recent Xcode.
- **Dark theme only** and designed for iPhone in portrait.
- **No unit or UI tests** in the project.
- **Structural inconsistencies:**
  - `ViewModels/` is a flat folder while `Models/` and `Views/` are nested by feature.
  - ViewModel class names are inconsistent (for example `TapFrenzyVM` inside `TapFrenzyViewModel.swift`).
  - `GamesSessionCoordinate.swift` has a naming typo and sits under `Extensions/`.
  - `TimerRing` lives in `QuizRush/Components/` instead of a shared folder.

---

## Reflection

Building PlayHub taught me how much MVVM helps once an app has more than one screen sharing data. Keeping timers and scoring in ViewModels, and putting session saving in one shared `StatusGame` object, meant Stats and Map updated without any extra wiring.

The hardest bugs were about timing. Saving a session inside an alert's OK action read a score that `resetGame()` had already zeroed, so I moved the save to `.onChange(of: vm.isGameOver)`. `Timer.publish(...).autoconnect()` also fires straight away, so every tick needed a guard on the game state. `GeometryReader` collapsed inside an `HStack` until I gave it an explicit frame.

If I had more time I would move persistence to SwiftData, add unit tests for the scoring and streak logic, and tidy the folder structure and ViewModel naming listed above.
