# Implementation Details

## Overview

This Flutter application implements a complete interval-based alarm reminder system that respects device ringer modes. The app is built using Flutter with native Android and iOS support.

## Architecture

### Design Pattern: Provider (State Management)

The app uses the Provider pattern for state management, which provides:
- Reactive UI updates
- Centralized state management
- Easy testing and maintainability

### Layered Architecture

```
Presentation Layer (Screens & Widgets)
    ↓
Business Logic Layer (Providers)
    ↓
Service Layer (Alarm, Database, Notification, Permission)
    ↓
Data Layer (Models & SQLite)
```

## Core Components

### 1. Data Model (`lib/models/reminder.dart`)

The `Reminder` class encapsulates all reminder data:
- Basic info: name, times, interval
- Schedule: active days, enabled state
- Audio: sound path, gradual volume
- Tracking: created date, last triggered time

Key methods:
- `getNextAlarmTime()`: Calculates the next scheduled alarm
- `getScheduledAlarmsForDay()`: Returns all alarm times for a specific day
- `toMap()` / `fromMap()`: Database serialization

### 2. Database Service (`lib/services/database_service.dart`)

Uses SQLite (`sqflite` package) for local persistence:

**Tables:**
- `reminders`: Stores reminder configurations
- `alarm_history`: Tracks alarm triggers and dismissals

**Operations:**
- CRUD operations for reminders
- Alarm history logging
- Statistics generation

### 3. Alarm Service (`lib/services/alarm_service.dart`)

Integrates the `alarm` and `sound_mode` packages:

**Key Features:**
- Ringer mode detection using `sound_mode` package
- Dynamic alarm scheduling based on ringer mode
- Supports up to 700 alarms per reminder (7 days × 100 alarms/day)
- Alarm ID generation: `reminderId * 10000 + dayOffset * 100 + alarmIndex`

**Ringer Mode Behavior:**
```dart
RingerModeStatus.normal  → Full sound + vibrate
RingerModeStatus.silent  → Vibrate only
RingerModeStatus.vibrate → Vibrate only
```

### 4. Notification Service (`lib/services/notification_service.dart`)

Handles local notifications using `flutter_local_notifications`:

**Features:**
- Full-screen intent for Android
- Time-sensitive notifications for iOS
- Scheduled notifications with timezone support
- Alarm and reminder notification channels

### 5. Permission Service (`lib/services/permission_service.dart`)

Manages runtime permissions:

**Required Permissions:**
- `notification` - Display notifications
- `scheduleExactAlarm` - Trigger alarms at precise times (Android 12+)
- `accessNotificationPolicy` - Detect ringer mode (Android 6+)

### 6. State Management (`lib/providers/reminder_provider.dart`)

The `ReminderProvider` class:
- Loads reminders from database on app start
- Provides CRUD operations to UI
- Coordinates with alarm service for scheduling
- Notifies UI of state changes

## Screen Flows

### Home Screen (`lib/screens/home_screen.dart`)

**Features:**
- Lists all reminders with status
- Pull-to-refresh functionality
- Quick toggle for enable/disable
- Delete confirmation dialog
- Listens for alarm events

**Alarm Listener:**
```dart
AlarmService.instance.alarmStream.listen((alarmSettings) {
  // Navigate to alarm ring screen
});
```

### Add/Edit Reminder Screen (`lib/screens/add_edit_reminder_screen.dart`)

**Form Fields:**
- Name (required)
- Start time (time picker)
- End time (time picker)
- Interval (dropdown)
- Active days (multi-select chips)
- Gradual volume (switch)

**Validation:**
- Name cannot be empty
- At least one day must be selected

### Alarm Ring Screen (`lib/screens/alarm_ring_screen.dart`)

**Features:**
- Full-screen display
- Animated alarm icon
- Dismiss button
- Multiple snooze options (5, 10, 15 minutes)
- Auto-dismisses on back button

## Alarm Scheduling Algorithm

### Initial Setup

1. User creates a reminder with:
   - Start: 9:00 AM
   - End: 10:00 PM
   - Interval: 1 hour
   - Days: Mon-Fri

2. System generates alarm times:
   - 9:00, 10:00, 11:00, ..., 22:00 (14 alarms per day)

3. Schedules alarms for next 7 days:
   - Only on selected days (Mon-Fri)
   - Only for future times

### Unique Alarm IDs

```
Alarm ID = reminderId × 10000 + dayOffset × 100 + alarmIndex

Example:
- Reminder ID: 1
- Day offset: 0 (today)
- Alarm index: 3 (third alarm of the day)
- Alarm ID: 1 × 10000 + 0 × 100 + 3 = 10003
```

This ensures:
- No ID collisions between reminders
- Easy cancellation of all reminders
- Support for 100 reminders with 700 alarms each

### Background Persistence

The `alarm` package handles background execution:
- Alarms trigger even when app is killed
- Uses `AlarmSettings.enableNotificationOnKill: true`
- Full-screen intent wakes the screen on Android

## Ringer Mode Integration

### Detection

```dart
final ringerMode = await SoundMode.ringerModeStatus;
```

Returns one of:
- `RingerModeStatus.normal`
- `RingerModeStatus.silent`
- `RingerModeStatus.vibrate`

### Dynamic Behavior

When scheduling an alarm:
1. Check current ringer mode
2. If silent/vibrate: Use silent audio file
3. If normal: Use selected alarm sound
4. Always enable vibration

### Real-time Updates

The alarm checks ringer mode at scheduling time, not at trigger time. For real-time updates:
- Could implement periodic checks
- Could use WorkManager for hourly reschedules
- Current implementation: User can manually refresh

## Database Schema

### Reminders Table

```sql
CREATE TABLE reminders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  startTime TEXT NOT NULL,        -- HH:mm format
  endTime TEXT NOT NULL,          -- HH:mm format
  intervalMinutes INTEGER NOT NULL,
  activeDays TEXT NOT NULL,       -- CSV: "1,2,3,4,5"
  isEnabled INTEGER NOT NULL,     -- Boolean: 0 or 1
  soundPath TEXT NOT NULL,
  snoozeCount INTEGER DEFAULT 0,
  maxSnoozes INTEGER DEFAULT 3,
  gradualVolume INTEGER DEFAULT 0,
  createdAt TEXT NOT NULL,        -- ISO 8601
  lastTriggered TEXT              -- ISO 8601
)
```

### Alarm History Table

```sql
CREATE TABLE alarm_history (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  reminderId INTEGER NOT NULL,
  triggeredAt TEXT NOT NULL,
  dismissedAt TEXT,
  snoozed INTEGER DEFAULT 0,
  FOREIGN KEY (reminderId) REFERENCES reminders (id) ON DELETE CASCADE
)
```

## Performance Considerations

### Optimization Strategies

1. **Limited Scheduling Window**: Only 7 days ahead
   - Reduces number of active alarms
   - Can be extended with periodic rescheduling

2. **Efficient Database Queries**:
   - Indexed primary keys
   - Query only enabled reminders for scheduling
   - Batch operations where possible

3. **Lazy Loading**:
   - Reminders loaded on demand
   - Statistics calculated when requested

4. **Memory Management**:
   - Streams for alarm events
   - Proper disposal of controllers

## Error Handling

### Database Errors
```dart
try {
  await _dbService.createReminder(reminder);
} catch (e) {
  print('Error adding reminder: $e');
  rethrow; // Let UI handle with SnackBar
}
```

### Permission Errors
- Graceful fallback if permissions denied
- UI prompts to open app settings
- Non-blocking initialization

### Alarm Scheduling Errors
- Try-catch around alarm.set()
- Log errors for debugging
- Retry mechanism for critical alarms

## Testing Strategy

### Unit Tests
- Model serialization/deserialization
- Alarm time calculation logic
- Database operations

### Widget Tests
- Screen rendering
- Form validation
- Navigation flows

### Integration Tests
- End-to-end reminder creation
- Alarm trigger simulation
- Database persistence

## Security Considerations

### Data Protection
- Local storage only (no cloud sync)
- No personal data collection
- SQLite database in app sandbox

### Permissions
- Request permissions at runtime
- Clear permission explanations
- Graceful degradation if denied

## Future Enhancements

### Potential Features
1. **Statistics Dashboard**:
   - Reminder completion rate
   - Most active reminders
   - Weekly/monthly graphs

2. **Custom Sound Library**:
   - Upload custom sounds
   - Sound preview player
   - Volume testing

3. **Smart Scheduling**:
   - Skip on holidays
   - Adjust based on location
   - Learn from user behavior

4. **Cloud Sync**:
   - Backup to cloud
   - Multi-device support
   - Share reminders

5. **Advanced Snooze**:
   - Intelligent snooze intervals
   - Snooze limits per reminder
   - Snooze patterns analysis

## Maintenance Notes

### Regular Tasks
1. Update dependencies monthly
2. Test on new Android/iOS versions
3. Monitor crash reports
4. Review permission changes in OS updates

### Known Limitations
1. Ringer mode checked at schedule time, not trigger time
2. Maximum 700 alarms per reminder
3. 7-day scheduling window
4. No cloud backup

## Troubleshooting

### Alarms Not Triggering
1. Check battery optimization settings
2. Verify SCHEDULE_EXACT_ALARM permission
3. Ensure app not in doze mode
4. Check notification permissions

### Permissions Not Granted
1. Open app settings
2. Enable required permissions
3. Restart app

### Database Errors
1. Clear app data
2. Reinstall app
3. Check storage permissions

## Build Configuration

### Android
- minSdk: 23 (Android 6.0)
- targetSdk: 34 (Android 14)
- Kotlin: 1.9.10
- Gradle: 8.3

### iOS
- Minimum: iOS 12.0
- Background modes: audio, fetch, processing
- Notification permissions required

## Package Versions

All packages are pinned to specific versions for stability:
- alarm: ^3.0.0
- sound_mode: ^2.0.3
- flutter_local_notifications: ^17.0.0
- workmanager: ^0.5.2
- provider: ^6.1.1
- sqflite: ^2.3.0
- permission_handler: ^11.0.1

Update with caution and test thoroughly.
