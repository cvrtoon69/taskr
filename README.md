# Taskr

**Plan. Do. Done.**

A premium dark-themed To-Do application built with Flutter for Android.

## Features

- **Task Management**: Create, edit, and organize tasks with priorities
- **Calendar View**: Visual calendar with task markers
- **Sub-tasks**: Break down tasks into manageable steps
- **Repeat Tasks**: Daily, weekly, and monthly recurring tasks
- **Notifications**: Local reminders for tasks
- **Progress Tracking**: Visual progress bar for task completion
- **Premium Dark UI**: Elegant dark-only design system

## Architecture

- **Clean Architecture**: Presentation, Domain, and Data layers
- **State Management**: Riverpod
- **Database**: Drift (SQLite)
- **DI**: Riverpod providers
- **Animations**: Custom animation system

## Project Structure

```
lib/
├── core/
│   ├── constants/      # App colors, theme, constants
│   ├── database/       # Drift database setup
│   ├── services/       # Notifications, haptics, settings
│   └── widgets/        # Reusable UI components
├── data/
│   ├── models/         # Data models
│   └── repositories/   # Repository implementations
├── domain/
│   ├── entities/       # Business entities
│   └── repositories/   # Repository interfaces
├── presentation/
│   ├── providers/      # Riverpod providers
│   ├── screens/        # UI screens
│   └── widgets/        # Screen-specific widgets
└── main.dart
```

## Build Instructions

### Prerequisites

- Flutter SDK (latest stable)
- Android SDK
- JDK 17

### Setup

1. Install Flutter dependencies:
```bash
cd taskr
flutter pub get
```

2. Run code generation for Drift:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Build APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Build AAB (Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

## App Details

- **Package Name**: com.rizowan.taskr
- **Min SDK**: 23 (Android 6.0)
- **Target SDK**: 34
- **Architecture**: Supports 32-bit and 64-bit (armeabi-v7a, arm64-v8a, x86_64)

## Signing

The app is configured with release signing:
- Keystore: `android/app/release.keystore`
- Alias: `taskr`
- Passwords: `taskrrelease`

For Play Store distribution, replace with your own keystore.

## Tech Stack

- Flutter 3.x
- Dart 3.x
- Riverpod 2.x
- Drift 2.x
- Flutter Local Notifications
- Phosphor Icons
- Table Calendar

## License

This project is for commercial use. All assets are original.

---

Made with ❤️ by Rizowan
