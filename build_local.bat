@echo off
echo ==========================================
echo Taskr - Local Build Script
echo ==========================================
echo.

REM Check if Flutter is installed
where flutter >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: Flutter is not installed or not in PATH
    echo.
    echo Please install Flutter:
    echo 1. Download from https://docs.flutter.dev/get-started/install/windows
    echo 2. Extract to C:\flutter
    echo 3. Add C:\flutter\bin to your PATH
    echo 4. Restart your terminal
echo.
    pause
    exit /b 1
)

echo Flutter found! Checking version...
flutter --version
echo.

REM Get dependencies
echo [1/4] Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo ERROR: Failed to get dependencies
    pause
    exit /b 1
)

REM Generate Drift code
echo.
echo [2/4] Generating database code...
flutter packages pub run build_runner build --delete-conflicting-outputs
if %errorlevel% neq 0 (
    echo WARNING: Code generation had issues, trying with delete...
    flutter packages pub run build_runner build --delete-conflicting-outputs
)

REM Build APK
echo.
echo [3/4] Building APK...
flutter build apk --release
if %errorlevel% neq 0 (
    echo ERROR: APK build failed
    pause
    exit /b 1
)

REM Build AAB
echo.
echo [4/4] Building AAB...
flutter build appbundle --release
if %errorlevel% neq 0 (
    echo WARNING: AAB build failed, but APK was built successfully
)

echo.
echo ==========================================
echo BUILD COMPLETED SUCCESSFULLY!
echo ==========================================
echo.
echo Output files:
echo   APK: build\app\outputs\flutter-apk\app-release.apk
echo   AAB: build\app\outputs\bundle\release\app-release.aab
echo.
pause
