# Interval-Based Alarm Reminder App

A Flutter application for setting interval-based alarm reminders that respect the device's ringer mode (silent/vibrate/normal).

## Features

- **Multiple Reminder Schedules**: Create multiple independent reminder schedules
- **Flexible Configuration**: 
  - Set start and end times
  - Configure intervals (15 min, 30 min, 1 hour, 2 hours, etc.)
  - Select active days of the week
  - Enable/disable reminders with a toggle
- **Smart Alarm Behavior**:
  - Normal Mode: Full alarm sound + vibrate + notification
  - Silent Mode: Only vibrate + notification
  - Vibrate Mode: Only vibrate + notification
- **Alarm Features**:
  - Full-screen alarm notifications
  - Snooze options (5, 10, 15 minutes)
  - Gradual volume increase option
  - Looping alarm sound until dismissed
- **Data Persistence**: All reminders saved locally using SQLite
- **Background Operation**: Alarms trigger even when app is closed

## Technical Stack

### Core Packages
- `alarm` (^3.0.0) - Alarm functionality with background support
- `sound_mode` (^2.0.3) - Device ringer mode detection
- `flutter_local_notifications` (^17.0.0) - Notification management
- `workmanager` (^0.5.2) - Background task scheduling
- `provider` (^6.1.1) - State management
- `sqflite` (^2.3.0) - Local database
- `permission_handler` (^11.0.1) - Permission management

## Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Android Studio or VS Code with Flutter extensions
- Android device/emulator (API 23+) or iOS device/simulator

### Installation

1. Clone the repository:
```bash
git clone https://github.com/sachin-tripathi99/reminder-app.git
cd reminder-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Add alarm sound files to `assets/sounds/` directory (e.g., default_alarm.mp3)

4. Run the app:
```bash
flutter run
```

## Usage

### Creating a Reminder

1. Tap the **+** button on the home screen
2. Enter a reminder name (e.g., "Drink Water", "Take Medicine")
3. Set start and end times
4. Choose an interval (e.g., every 1 hour)
5. Select active days of the week
6. Optionally enable gradual volume increase
7. Tap "Create Reminder"

### Managing Reminders

- **Toggle**: Use the switch on each reminder card to enable/disable
- **Edit**: Tap on a reminder card to edit its settings
- **Delete**: Tap the delete button to remove a reminder
- **Refresh**: Use the refresh button in the app bar to reschedule all alarms

### When an Alarm Triggers

- A full-screen alarm screen will appear
- **Dismiss**: Tap the dismiss button to stop the alarm
- **Snooze**: Choose 5, 10, or 15 minutes to snooze

## Permissions

The app requires the following permissions:

- **Notifications**: To display alarm notifications
- **Schedule Exact Alarms**: To trigger alarms at precise times
- **Access Notification Policy**: To detect device ringer mode
- **Vibrate**: For vibration alerts
- **Wake Lock**: To wake the screen for alarms

## Platform-Specific Notes

### Android
- Minimum SDK: 23 (Android 6.0)
- Target SDK: 34
- Requires permission for scheduling exact alarms (Android 12+)
- Full-screen intent permission needed for alarm screen

### iOS
- Background audio capability required
- Push notification permission needed

## Architecture

```
lib/
├── main.dart                      # App entry point
├── models/
│   └── reminder.dart              # Reminder data model
├── services/
│   ├── database_service.dart      # SQLite database operations
│   ├── alarm_service.dart         # Alarm scheduling and management
│   ├── notification_service.dart  # Notification handling
│   └── permission_service.dart    # Permission management
├── providers/
│   └── reminder_provider.dart     # State management
├── screens/
│   ├── home_screen.dart           # Main screen with reminder list
│   ├── add_edit_reminder_screen.dart  # Add/Edit reminder form
│   └── alarm_ring_screen.dart     # Full-screen alarm interface
└── widgets/
    └── reminder_card.dart         # Reminder list item widget
```

## Example Use Case

Create a "Drink Water" reminder:
- Start: 9:00 AM
- End: 10:00 PM
- Interval: Every 1 hour
- Days: Monday to Friday
- Result: Alarms at 9 AM, 10 AM, 11 AM... until 10 PM on weekdays

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For issues and feature requests, please file an issue on the GitHub repository.