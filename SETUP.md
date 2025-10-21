# Setup Guide

This guide will help you set up and run the Interval-Based Alarm Reminder App.

## Prerequisites

Before you begin, ensure you have the following installed:

### Required Software

1. **Flutter SDK** (version 3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH

2. **Android Studio** (for Android development)
   - Download from: https://developer.android.com/studio
   - Install Android SDK (API 23 or higher)
   - Install Android SDK Command-line Tools

3. **Xcode** (for iOS development, macOS only)
   - Download from Mac App Store
   - Install Xcode Command Line Tools

4. **Git**
   - For version control
   - Download from: https://git-scm.com/downloads

### Optional but Recommended

- **VS Code** with Flutter/Dart extensions
- **Android Emulator** or physical Android device
- **iOS Simulator** or physical iOS device (macOS only)

## Installation Steps

### 1. Verify Flutter Installation

Open a terminal and run:

```bash
flutter doctor
```

Ensure all required dependencies are installed. Address any issues shown.

### 2. Clone the Repository

```bash
git clone https://github.com/sachin-tripathi99/reminder-app.git
cd reminder-app
```

### 3. Install Dependencies

```bash
flutter pub get
```

This will download all required packages specified in `pubspec.yaml`.

### 4. Add Alarm Sound Files

The app requires actual alarm sound files to function properly.

1. Navigate to `assets/sounds/` directory
2. Add MP3 or WAV files for alarm sounds
3. Recommended sounds:
   - `default_alarm.mp3` (default alarm sound)
   - `silent.mp3` (very short silent audio, ~0.1 seconds)

You can:
- Use your own sound files
- Download free alarm sounds from sites like [Freesound.org](https://freesound.org/)
- Create a silent audio file using audio editing software

**Important:** Update the sound paths in the code if you use different filenames.

### 5. Configure Android

#### a. Update local.properties (if needed)

Create `android/local.properties` with your SDK path:

```properties
sdk.dir=/path/to/your/Android/sdk
flutter.sdk=/path/to/your/flutter/sdk
```

#### b. Enable Developer Options on Android Device

1. Go to Settings > About phone
2. Tap "Build number" 7 times
3. Go back to Settings > Developer options
4. Enable "USB debugging"

### 6. Configure iOS (macOS only)

```bash
cd ios
pod install
cd ..
```

### 7. Run the App

#### On Android

```bash
# List available devices
flutter devices

# Run on connected device/emulator
flutter run

# Run in release mode
flutter run --release
```

#### On iOS (macOS only)

```bash
# Open iOS simulator
open -a Simulator

# Run on simulator
flutter run

# Run in release mode
flutter run --release
```

## Configuration

### Permissions

The app will request the following permissions at runtime:

- **Notifications**: Required for alarm notifications
- **Schedule Exact Alarms**: Required for precise alarm timing (Android 12+)
- **Access Notification Policy**: Required to detect ringer mode
- **Vibrate**: Required for vibration alerts

### Android Specific

#### Battery Optimization

For reliable alarms, disable battery optimization:

1. Go to Settings > Apps > Reminder App
2. Battery > Optimize battery usage
3. Find Reminder App and set to "Don't optimize"

#### Do Not Disturb

To detect ringer mode properly:

1. Settings > Apps > Reminder App > Permissions
2. Grant "Access to Do Not Disturb" permission

### iOS Specific

#### Background Modes

Ensure background modes are enabled in Xcode:

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to "Signing & Capabilities"
4. Add "Background Modes" capability
5. Enable:
   - Audio, AirPlay, and Picture in Picture
   - Background fetch
   - Background processing

## Troubleshooting

### Flutter Doctor Issues

**Issue:** Flutter not found
```bash
# Add Flutter to PATH (Linux/macOS)
export PATH="$PATH:/path/to/flutter/bin"

# Add to ~/.bashrc or ~/.zshrc for persistence
```

**Issue:** Android licenses not accepted
```bash
flutter doctor --android-licenses
```

### Build Errors

**Issue:** Gradle build fails
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**Issue:** iOS pod install fails
```bash
cd ios
pod deintegrate
pod install
cd ..
```

### Runtime Issues

**Issue:** Alarms not triggering
- Check notification permissions
- Disable battery optimization
- Ensure exact alarm permission granted (Android 12+)

**Issue:** No sound when alarm triggers
- Verify sound files exist in `assets/sounds/`
- Check device volume settings
- Ensure not in silent mode (unless intended)

**Issue:** App crashes on launch
- Check logs: `flutter logs`
- Clear app data and reinstall
- Verify all dependencies installed

### Common Errors

**Error:** "Gradle task assembleDebug failed with exit code 1"
```bash
# Update Gradle wrapper
cd android
./gradlew wrapper --gradle-version 8.3
cd ..
```

**Error:** "MissingPluginException"
```bash
flutter clean
flutter pub get
```

**Error:** "Unable to load asset"
- Ensure `pubspec.yaml` includes `assets/sounds/` in flutter section
- Run `flutter clean` and `flutter pub get`

## Building for Release

### Android APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

### Android App Bundle (for Play Store)

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### iOS (macOS only)

```bash
flutter build ios --release
```

Then open Xcode to archive and upload to App Store.

## Testing

### Run Unit Tests

```bash
flutter test
```

### Run with Coverage

```bash
flutter test --coverage
```

### Run on Specific Device

```bash
# List devices
flutter devices

# Run on specific device
flutter run -d <device-id>
```

## Development Tips

### Hot Reload

While the app is running, press `r` in the terminal for hot reload or `R` for hot restart.

### Debugging

```bash
# Run in debug mode with verbose logging
flutter run --verbose

# View logs
flutter logs
```

### Code Analysis

```bash
# Run static analysis
flutter analyze

# Format code
flutter format lib/
```

## Environment Variables

Create `.env` file for environment-specific configuration (optional):

```env
ENVIRONMENT=development
DEBUG_MODE=true
```

## Additional Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)
- [Provider Package](https://pub.dev/packages/provider)
- [Alarm Package](https://pub.dev/packages/alarm)
- [Sound Mode Package](https://pub.dev/packages/sound_mode)

## Support

For issues and questions:
- Check existing [GitHub Issues](https://github.com/sachin-tripathi99/reminder-app/issues)
- Create a new issue with detailed information
- Review IMPLEMENTATION.md for technical details

## Next Steps

After successful setup:
1. Run the app and create your first reminder
2. Test alarm functionality
3. Review the code structure
4. Make your first contribution!

---

**Note:** This is an open-source project. Feel free to modify and extend as needed!
