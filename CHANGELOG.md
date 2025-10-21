# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-10-21

### Added
- Initial release of Interval-Based Alarm Reminder App
- Multiple reminder schedule support
- Configurable time ranges (start time, end time)
- Flexible interval settings (15 min, 30 min, 1 hour, 2 hours, 3 hours, 4 hours)
- Day-of-week selector for active days
- Ringer mode detection and respect (normal/silent/vibrate)
- Full-screen alarm notifications
- Snooze functionality (5, 10, 15 minutes)
- Dismiss alarm feature
- Enable/disable toggle for each reminder
- Gradual volume increase option
- SQLite database for local persistence
- Alarm history tracking
- Statistics for reminder completion
- Background alarm triggering
- Home screen with reminder list
- Add/Edit reminder screen with form validation
- Alarm ring screen with animated UI
- Material Design 3 UI
- Pull-to-refresh on home screen
- Delete confirmation dialog
- Permission management system
- Android support (API 23+)
- iOS support
- Comprehensive documentation
- MIT License

### Technical Features
- Provider state management
- SQLite database with alarm history
- Integration with `alarm` package for reliable alarms
- Integration with `sound_mode` package for ringer detection
- Local notifications with `flutter_local_notifications`
- Runtime permission handling with `permission_handler`
- Timezone support for accurate scheduling
- Unique alarm ID generation algorithm
- Support for up to 100 reminders with 700 alarms each
- 7-day rolling alarm schedule window

### Known Limitations
- Ringer mode checked at schedule time, not trigger time
- Maximum 700 alarms per reminder
- 7-day scheduling window
- No cloud backup functionality
- Requires actual audio files for alarm sounds (placeholders provided)
