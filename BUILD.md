# Building Taskr

## Quick Build Guide

### 1. Install Flutter

Download and install Flutter SDK from https://docs.flutter.dev/get-started/install

Verify installation:
```bash
flutter doctor
```

### 2. Get Dependencies

```bash
cd c:\Users\RDP\Desktop\taskr
flutter pub get
```

### 3. Generate Code

Drift requires code generation:

```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

If you get conflicts, run:
```bash
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### 4. Build Release APK

```bash
flutter build apk --release
```

The APK will be at:
`build/app/outputs/flutter-apk/app-release.apk`

### 5. Build Release AAB (for Play Store)

```bash
flutter build appbundle --release
```

The AAB will be at:
`build/app/outputs/bundle/release/app-release.aab`

### 6. Build for Both Architectures

The app already supports both 32-bit and 64-bit:
- armeabi-v7a (32-bit)
- arm64-v8a (64-bit)
- x86_64 (64-bit emulator)

## Troubleshooting

### Drift code generation fails
```bash
flutter clean
flutter pub get
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Android build issues
```bash
cd android
./gradlew clean
cd ..
flutter build apk --release
```

### Signing issues
The release keystore is at `android/app/release.keystore`. For production, replace with your own keystore.

## Testing

### Run on device
```bash
flutter run
```

### Run tests
```bash
flutter test
```

## Project Stats

- Total Dart files: ~35
- Screens: 6
- Custom widgets: 10+
- Database tables: 2
- Repository implementations: 2
