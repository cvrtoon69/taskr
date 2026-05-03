# Taskr - Quick Start Guide

## Option 1: GitHub Actions (Easiest - No Installation Required)

### Step 1: Create a GitHub Repository
1. Go to https://github.com/new
2. Name it `taskr`
3. Make it public or private
4. Click **Create repository**

### Step 2: Upload Your Code

Open terminal in the taskr folder and run:

```bash
cd c:\Users\RDP\Desktop\taskr
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/taskr.git
git push -u origin main
```

Replace `YOUR_USERNAME` with your actual GitHub username.

### Step 3: Get Your APK

1. Go to your GitHub repository page
2. Click **Actions** tab
3. Wait for the workflow to complete (~5-10 minutes)
4. Click on the completed workflow run
5. Scroll to **Artifacts** section
6. Download `taskr-apk` - it contains `app-release.apk`

## Option 2: Build Locally (Requires Flutter Installation)

### Step 1: Install Flutter

1. Download Flutter SDK from https://docs.flutter.dev/get-started/install/windows
2. Extract to `C:\flutter`
3. Add `C:\flutter\bin` to your system PATH:
   - Search "Environment Variables" in Windows search
   - Click "Edit the system environment variables"
   - Click "Environment Variables"
   - Find "Path" in User variables, click Edit
   - Click New, add `C:\flutter\bin`
   - Click OK on all dialogs
4. Restart your terminal/IDE
5. Verify: `flutter doctor`

### Step 2: Run Build Script

Double-click `build_local.bat` in the taskr folder, or run:

```bash
cd c:\Users\RDP\Desktop\taskr
build_local.bat
```

The script will:
1. Get dependencies
2. Generate database code
3. Build APK
4. Build AAB

Output locations:
- APK: `build\app\outputs\flutter-apk\app-release.apk`
- AAB: `build\app\outputs\bundle\release\app-release.aab`

## Option 3: Use an Online Flutter Builder

Some online services can build Flutter apps:
- Codemagic (https://codemagic.io)
- GitHub Actions (already configured in this project)

## Installing the APK on Android

1. Enable "Install from Unknown Sources" in Android settings
2. Transfer `app-release.apk` to your phone
3. Tap the APK file to install
4. Open Taskr and start planning!

## Next Steps

### For Play Store Upload

1. Create a Google Play Developer account ($25 one-time fee)
2. Use the AAB file (app-release.aab)
3. Create a new app in Play Console
4. Upload the AAB to Play Console
5. Complete the app listing and publish

### For Custom Signing

Replace the test keystore with your production keystore:
1. Generate new keystore: `keytool -genkey -v -keystore release.keystore ...`
2. Update `android/app/build.gradle` with your keystore details
3. Rebuild

## Support

If you encounter issues:
1. Check BUILD.md for detailed instructions
2. Check .github/workflows/README.md for CI troubleshooting
3. Run `flutter doctor` to check your environment (local builds)

---

**Recommended**: Use Option 1 (GitHub Actions) for the easiest build experience without installing anything!
