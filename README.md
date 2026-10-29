# 🌿 HabitFlow — Daily Habit Tracker

> *Build tiny habits. Compound massive wins.*

HabitFlow is a production-quality, offline-first daily habit tracker crafted for students and young professionals. Designed with Google's Material 3 design system, calm Gen-Z aesthetics (#0B0F14 deep dark mode), and a responsive Flutter architecture, HabitFlow helps users conquer procrastination, stay mindful, and build momentum through visual streaks and focus sessions.

---

## 🎯 Problem Statement

Most habit apps on the app store are either cluttered with intrusive ads, bloated subscription paywalls, or require mandatory online sign-ins that compromise user privacy. Students and busy professionals need an intuitive, distraction-free companion that works 100% offline, starts instantly without onboarding friction, and presents clear, motivating progress.

HabitFlow solves this with a **zero-login, zero-cloud, 100% private, and local-first** experience.

---

## ✨ Features

- **✅ Daily Habit Tracking**: Mark habits complete with a tactile tap, satisfying animations, and instant progress feedback.
- **🔄 Undo / Toggle Flexibility**: Accidental click? Easily undo a completion status for today without breaking consistency.
- **🔥 Accurate Streak Engine**: Real streaks calculated strictly from consecutive days. Accurately handles same-day completions and yesterday's grace period.
- **⏱️ Focus Mode**: Built-in interval focus timer (5, 10, 15, 25, 45 minutes) featuring a calming animated breathing circle. Prompt upon completion to automatically mark your habit done.
- **🔮 Habit Impact Simulator ("Tomorrow Simulator")**: Interactive projection slider (7 to 90 days) showing future streak milestones, total action counts, and habit growth stages (Sprout Seedling 🌱 ➔ Golden Oak 🌟).
- **📊 Insights & Analytics**:
  - Today's completion rate and progress ring
  - 7-day consistency bar chart (custom lightweight widget)
  - Star habit showcase & "Needs a Little Boost" habit nudge
  - Total all-time wins & longest streak tracker
  - Category-by-category completion rates
- **🏷️ Smart Categories**: Health, Study, Fitness, Mindfulness, Productivity, Personal, and Custom with distinct color signatures and icons.
- **🎨 Calm Dark Aesthetic**: Material 3 dark surface (#141B23) with mint green (#34D399), electric teal (#22D3EE), and soft violet (#A78BFA) accents. Optional light theme toggle.
- **💾 Local Persistence**: Fast, reliable JSON serialization powered by `shared_preferences`. Data survives app restarts and OS reboots.
- **🔒 Privacy by Design**: No accounts, no telemetry, no analytics, no ads, no internet permissions.
- **📤 Export & Reset**: Export your habits as formatted JSON text to clipboard anytime, or perform a total factory reset with confirmation safeguard.

---

## 📱 Screenshots & UI Architecture

```
┌─────────────────────────────────┐   ┌─────────────────────────────────┐   ┌─────────────────────────────────┐
│ Good morning, Alex 👋           │   │ Habit Insights 📊               │   │ Settings ⚙️                     │
│ Thursday, Oct 29                │   │ ─────────────────────────────── │   │ ─────────────────────────────── │
│ ─────────────────────────────── │   │ ┌─────────────────────────────┐ │   │ PREFERENCES                     │
│ ┌─────────────────────────────┐ │   │ │ Today: 75% Complete         │ │   │ [🌙] Dark Mode       [ON]       │
│ │ 3 of 4 completed            │ │   │ │ 3 of 4 habits done today    │ │   │ [👤] Your Name       Alex       │
│ │ "Almost there. Finish strong"│ │  │ └─────────────────────────────┘ │   │                                 │
│ └─────────────────────────────┘ │   │ ┌──────────────┬──────────────┐ │   │ DATA & BACKUP                   │
│ [All] [Study] [Health] [Fitness]│   │ │ Wins: 42     │ Streak: 7d   │ │   │ [📥] Export Habits as JSON      │
│                                 │   │ └──────────────┴──────────────┘ │   │ [🗑️] Reset All Data             │
│ [💧 Drink 2L Water   🔥 3d  ✓]  │   │ Last 7 Days Consistency Chart   │   │                                 │
│ [📚 Read 20 Mins     🔥 5d  ✓]  │   │ ▄ █ ▄ █ █ █ █ (Mon - Sun)       │   │ PRIVACY & ETHICS                │
│ [💻 Code Review      🔥 2d  ○]  │   │                                 │   │ "HabitFlow stores all data on   │
│                                 │   │ 🌟 Habit Impact Simulator       │   │  your device only."             │
│            [+ New Habit]        │   │ Projection: 30 Days (🌳 Tree)   │   │ Version 1.0.0                   │
└─────────────────────────────────┘   └─────────────────────────────────┘   └─────────────────────────────────┘
           [ Today ]                             [ Insights ]                          [ Settings ]
```

---

## 🛠️ Tech Stack & Dependencies

- **Framework**: [Flutter 3.x](https://flutter.dev) (Channel stable, Material 3)
- **Language**: [Dart 3.x](https://dart.dev) (OOP, null-safety, records, functional iterators)
- **State Management**: `ChangeNotifier` + `ListenableBuilder` (Zero external state bloat, ideal for interviews)
- **Local Storage**: [`shared_preferences`](https://pub.dev/packages/shared_preferences)
- **Internationalization & Dates**: [`intl`](https://pub.dev/packages/intl)
- **Typography**: [`google_fonts`](https://pub.dev/packages/google_fonts) (Inter for body, Sora for headings)
- **Testing**: `flutter_test` (100% pass on model OOP, streak algorithms, and widget rendering)

---

## 🏗️ Architecture & Clean Design Pattern

HabitFlow uses a clean separation of concerns separating **Models**, **Services**, **State Providers**, **Widgets**, and **Screens**:

```
habitflow/
├── lib/
│   ├── main.dart                      # App entry point, async service initialization
│   ├── app.dart                       # Root MaterialApp, theme switching, tab navigation scaffold
│   ├── models/
│   │   └── habit.dart                 # OOP Habit entity, encapsulation, copyWith, serialization
│   ├── services/
│   │   ├── habit_storage_service.dart # Local SharedPreferences persistence and JSON parsing
│   │   └── streak_service.dart        # Pure streak algorithms, weekly math, simulation projections
│   ├── providers/
│   │   └── habit_provider.dart        # Central state, computed statistics, motivational logic
│   ├── screens/
│   │   ├── home_screen.dart           # Dashboard with greeting, progress ring, habit list, FAB
│   │   ├── insights_screen.dart       # 7-day bar chart, best habit, simulator slider
│   │   ├── settings_screen.dart       # Preferences, name customization, JSON export, reset
│   │   ├── add_edit_habit_screen.dart # Form validation, emoji picker, reminders, target selector
│   │   └── focus_mode_screen.dart     # Calming breathing timer, interval presets, completion hook
│   ├── widgets/
│   │   ├── habit_card.dart            # Interactive card with scale animation and popup menu
│   │   ├── progress_ring.dart         # Custom-painted circular progress with gradient stroke
│   │   ├── streak_badge.dart          # Flame badge indicator with glow borders
│   │   ├── category_chip.dart         # Distinct color-coded category pills
│   │   ├── empty_state.dart           # Illustrated friendly empty state
│   │   └── confirmation_dialog.dart   # Reusable confirmation dialog for dangerous actions
│   └── theme/
│       └── app_theme.dart             # Dark and Light Material 3 theme configurations
├── test/
│   ├── habit_test.dart                # Unit tests for OOP methods, streaks, and serialization
│   └── widget_test.dart               # Widget smoke tests for custom UI components
├── pubspec.yaml                       # Dependencies and asset declarations
└── README.md                          # Project documentation
```

---

## 🚀 Setup & Running the App

### Prerequisites
1. Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.13+ recommended).
2. Install Android Studio or VS Code with Flutter extension.
3. Android device with USB debugging enabled OR an active Android Emulator.

### Installation Steps

```bash
# 1. Clone the repository
git clone https://github.com/your-username/habitflow.git
cd habitflow

# 2. Get dependencies
flutter pub get

# 3. Analyze code quality (0 issues guaranteed)
flutter analyze

# 4. Run automated test suite
flutter test

# 5. Run on connected Android device or emulator
flutter run
```

---

## 📦 How to Build a Release APK

To create an optimized release APK for distribution or sideloading onto your Android device:

```bash
# Build standalone release APK
flutter build apk --release

# The compiled APK will be located at:
# build/app/outputs/flutter-apk/app-release.apk
```

For Google Play Store submission (Android App Bundle):
```bash
flutter build appbundle --release
# Bundle located at: build/app/outputs/bundle/release/app-release.aab
```

---

## 🔒 Privacy Policy

> **HabitFlow does not collect, share, or transmit your personal data. Your habits, streaks, and preferences are stored only on your device. You can delete all data anytime from Settings.**

- **Offline-First**: All habit data is stored locally in the device's private application storage (`SharedPreferences`).
- **No Analytics / Telemetry**: No tracking SDKs (no Firebase, no Mixpanel, no Facebook SDK).
- **No Ads**: Distraction-free, zero third-party network calls.

---

## 🎓 GDG (Google Developer Groups) Interview Q&A

This section is prepared specifically to help first-year students and junior developers explain the design and code during developer interviews.

### Q1: Why did you choose `ChangeNotifier` and `ListenableBuilder` over third-party state libraries like Bloc or Riverpod?
> **Answer**: For an offline-first habit tracker, `ChangeNotifier` is part of Flutter's built-in `foundation` package. It provides simple, transparent reactivity with `notifyListeners()`. Combined with `ListenableBuilder`, only the widgets that depend on state rebuild when changes happen. This keeps the codebase beginner-friendly, eliminates unnecessary boilerplate, reduces the APK size, and avoids third-party dependency vulnerabilities while demonstrating a solid grasp of core Flutter fundamentals.

### Q2: How is the Habit streak calculated without bugs or fake data?
> **Answer**: Habit completion timestamps are normalized to day-only values (`DateTime(year, month, day)`) to avoid time-of-day discrepancy. To compute the active streak, we determine whether the user completed the habit today or yesterday. If completed today, we count backwards consecutively day by day. If not yet completed today, but completed yesterday, yesterday counts as the anchor day so the user has the remainder of today to maintain their streak. If both today and yesterday were missed, the active streak resets to 0.

### Q3: How do you achieve encapsulation and OOP principles in Dart?
> **Answer**: In `Habit`, fields like `_completionDates` are kept private so external widgets cannot directly modify the list. Callers access the list through a read-only getter `List<DateTime> get completionDates => List.unmodifiable(_completionDates);`. State updates follow the immutable `copyWith` pattern and domain methods like `toggleCompletionForToday()`, ensuring single-source-of-truth updates and predictable behavior.

### Q4: How is local persistence implemented and protected against corruption?
> **Answer**: `HabitStorageService` encapsulates `SharedPreferences`. The habit list is encoded into JSON strings with `jsonEncode` and deserialized using `Habit.fromJson`. To prevent crashes, corrupted data is caught inside `try/catch` blocks and falls back gracefully to safe empty collections. Additionally, data is written immediately whenever a user adds, edits, completes, or deletes a habit.

### Q5: How is Material 3 applied in the dark theme?
> **Answer**: We configure `ThemeData(useMaterial3: true)` with a deep dark background (`#0B0F14`), distinct surface container levels (`#141B23`), rounded corners (18–24px), custom Typography (Sora for headings, Inter for body), and primary mint green (`#34D399`) accents to deliver a modern, calm, and readable visual experience.

---

## 🔮 Future Improvements

- Home screen widgets (Android Glance / AppWidget)
- Sound effects or haptic vibration feedback on habit completion
- Local notification reminders using `flutter_local_notifications`
- Weekly PDF summary report export

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.
