# GitHub Actions Build Workflow

This workflow automatically builds the Taskr APK and AAB on every push to main/master branch.

## How to Use

### 1. Push to GitHub

Upload your code to a GitHub repository:

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/taskr.git
git push -u origin main
```

### 2. Trigger a Build

The workflow runs automatically on every push. To trigger manually:

1. Go to your GitHub repository
2. Click on **Actions** tab
3. Select **Build Taskr APK** workflow
4. Click **Run workflow** button

### 3. Download the APK

After the build completes (takes ~5-10 minutes):

1. Go to the completed workflow run
2. Scroll down to **Artifacts** section
3. Download:
   - `taskr-apk` - Contains `app-release.apk`
   - `taskr-aab` - Contains `app-release.aab` (for Play Store)

## Build Outputs

The workflow produces:

| Artifact | File | Purpose |
|----------|------|---------|
| taskr-apk | app-release.apk | Install directly on Android devices |
| taskr-aab | app-release.aab | Upload to Google Play Store |

## Creating a Release

To create a release with the APK attached:

```bash
git tag v1.0.0
git push origin v1.0.0
```

The workflow will automatically attach the APK and AAB to the GitHub release.

## Workflow Details

- **Runner**: Ubuntu Latest
- **Flutter Version**: 3.19.0 (stable)
- **Java Version**: 17 (Temurin)
- **Build Time**: ~5-10 minutes

## Troubleshooting

### Build fails on Drift generation
The workflow runs `build_runner` automatically. If it fails, check:
1. All `@drift` annotations are correct in `lib/core/database/`
2. No syntax errors in table definitions

### APK signing issues
The APK is signed with the debug keystore for CI builds. For production:
1. Add your release keystore as a GitHub Secret
2. Update the workflow to use the secret for signing
