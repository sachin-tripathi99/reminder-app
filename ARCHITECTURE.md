# Architecture Diagram

## System Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    Interval Reminder App                         │
│                      Flutter Application                         │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                      PRESENTATION LAYER                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Home Screen  │  │ Add/Edit     │  │ Alarm Ring   │          │
│  │              │  │ Screen       │  │ Screen       │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                   │
│  ┌──────────────────────────────────────────────────┐           │
│  │         Widgets (Reminder Card)                   │           │
│  └──────────────────────────────────────────────────┘           │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                   BUSINESS LOGIC LAYER                           │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │            Reminder Provider (State Management)             │ │
│  │                    - ChangeNotifier                         │ │
│  │                    - CRUD Operations                        │ │
│  │                    - Alarm Coordination                     │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                       SERVICE LAYER                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Alarm        │  │ Database     │  │ Notification │          │
│  │ Service      │  │ Service      │  │ Service      │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                   │
│  ┌──────────────────────────────────────────────────┐           │
│  │         Permission Service                        │           │
│  └──────────────────────────────────────────────────┘           │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                        DATA LAYER                                │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    SQLite Database                          │ │
│  │  ┌──────────────────┐    ┌──────────────────┐             │ │
│  │  │ reminders table  │    │ alarm_history    │             │ │
│  │  └──────────────────┘    └──────────────────┘             │ │
│  └────────────────────────────────────────────────────────────┘ │
│                                                                   │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │                    Data Models                              │ │
│  │              (Reminder, AlarmHistory)                       │ │
│  └────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────┘
                              ↕
┌─────────────────────────────────────────────────────────────────┐
│                    EXTERNAL INTEGRATIONS                         │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │ Alarm Pkg    │  │ Sound Mode   │  │ Notifications│          │
│  │ (Background) │  │ (Ringer)     │  │ (Local)      │          │
│  └──────────────┘  └──────────────┘  └──────────────┘          │
│                                                                   │
│  ┌──────────────────────────────────────────────────┐           │
│  │         Permission Handler & WorkManager         │           │
│  └──────────────────────────────────────────────────┘           │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow

### Creating a Reminder

```
User Input (UI)
    ↓
Add/Edit Screen (Form)
    ↓
Validation
    ↓
Reminder Provider
    ↓
Database Service ───→ Save to SQLite
    ↓
Alarm Service ───→ Schedule Alarms
    ↓
System Alarm Manager
    ↓
UI Update (Home Screen)
```

### Alarm Trigger Flow

```
Scheduled Time Reached
    ↓
System Alarm Manager
    ↓
Alarm Package (Background)
    ↓
Check Ringer Mode (sound_mode)
    ↓
Play Sound/Vibrate/Silent
    ↓
Show Full-Screen Notification
    ↓
Navigate to Alarm Ring Screen
    ↓
User Action (Dismiss/Snooze)
    ↓
Update Database (History)
    ↓
Stop Alarm / Reschedule Snooze
```

## Component Relationships

```
┌─────────────────────────────────────────────────────────────────┐
│                         main.dart                                │
│                    (App Entry Point)                             │
└────────────────────────┬────────────────────────────────────────┘
                         │
                         ↓
         ┌───────────────┴───────────────┐
         │   Initialize Services          │
         │   - Alarm Service              │
         │   - Notification Service       │
         │   - Permission Service         │
         └───────────────┬───────────────┘
                         │
                         ↓
         ┌───────────────┴───────────────┐
         │   Setup Provider               │
         │   - ReminderProvider           │
         └───────────────┬───────────────┘
                         │
                         ↓
         ┌───────────────┴───────────────┐
         │   Material App                 │
         │   - Home Screen                │
         └────────────────────────────────┘
```

## State Management Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    ReminderProvider                              │
│                  (ChangeNotifier)                                │
│                                                                   │
│  State:                                                          │
│  - List<Reminder> _reminders                                    │
│  - bool _isLoading                                              │
│                                                                   │
│  Methods:                                                        │
│  - loadReminders()                                              │
│  - addReminder(reminder)                                        │
│  - updateReminder(reminder)                                     │
│  - deleteReminder(id)                                           │
│  - toggleReminder(id)                                           │
│                                                                   │
│  Notifies:                                                       │
│  - Home Screen                                                   │
│  - Reminder Cards                                               │
└─────────────────────────────────────────────────────────────────┘
         │                    │                    │
         ↓                    ↓                    ↓
   ┌─────────┐          ┌─────────┐          ┌─────────┐
   │ UI Auto │          │ Database│          │ Alarm   │
   │ Updates │          │ Service │          │ Service │
   └─────────┘          └─────────┘          └─────────┘
```

## Service Layer Details

### Alarm Service

```
┌─────────────────────────────────────────────────────────────────┐
│                      AlarmService                                │
│                                                                   │
│  Responsibilities:                                               │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │ 1. Check ringer mode (sound_mode package)              │   │
│  │ 2. Generate unique alarm IDs                           │   │
│  │ 3. Schedule alarms with alarm package                  │   │
│  │ 4. Handle snooze functionality                         │   │
│  │ 5. Cancel alarms when reminder disabled               │   │
│  └─────────────────────────────────────────────────────────┘   │
│                                                                   │
│  Key Algorithm:                                                  │
│  AlarmID = reminderID × 10000 + dayOffset × 100 + alarmIndex   │
└─────────────────────────────────────────────────────────────────┘
```

### Database Service

```
┌─────────────────────────────────────────────────────────────────┐
│                    DatabaseService                               │
│                                                                   │
│  Tables:                                                         │
│  ┌─────────────────────────┐  ┌─────────────────────────┐      │
│  │  reminders              │  │  alarm_history          │      │
│  │  - id (PK)              │  │  - id (PK)              │      │
│  │  - name                 │  │  - reminderId (FK)      │      │
│  │  - startTime            │  │  - triggeredAt          │      │
│  │  - endTime              │  │  - dismissedAt          │      │
│  │  - intervalMinutes      │  │  - snoozed              │      │
│  │  - activeDays           │  └─────────────────────────┘      │
│  │  - isEnabled            │                                     │
│  │  - soundPath            │                                     │
│  │  - settings...          │                                     │
│  └─────────────────────────┘                                     │
└─────────────────────────────────────────────────────────────────┘
```

## Platform Integration

### Android Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Android Platform                            │
│                                                                   │
│  AndroidManifest.xml                                            │
│  ┌────────────────────────────────────────┐                    │
│  │ Permissions:                            │                    │
│  │ - SCHEDULE_EXACT_ALARM                 │                    │
│  │ - POST_NOTIFICATIONS                   │                    │
│  │ - ACCESS_NOTIFICATION_POLICY           │                    │
│  │ - WAKE_LOCK                            │                    │
│  │ - USE_FULL_SCREEN_INTENT              │                    │
│  │ - VIBRATE                              │                    │
│  └────────────────────────────────────────┘                    │
│                                                                   │
│  MainActivity.kt                                                │
│  ┌────────────────────────────────────────┐                    │
│  │ FlutterActivity                        │                    │
│  │ - Handles platform channels            │                    │
│  │ - Manages app lifecycle                │                    │
│  └────────────────────────────────────────┘                    │
└─────────────────────────────────────────────────────────────────┘
```

### iOS Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        iOS Platform                              │
│                                                                   │
│  Info.plist                                                      │
│  ┌────────────────────────────────────────┐                    │
│  │ Background Modes:                      │                    │
│  │ - audio                                │                    │
│  │ - fetch                                │                    │
│  │ - processing                           │                    │
│  │                                         │                    │
│  │ Permissions:                            │                    │
│  │ - Notifications                        │                    │
│  └────────────────────────────────────────┘                    │
└─────────────────────────────────────────────────────────────────┘
```

## Alarm Scheduling Logic

### Schedule Generation

```
Input: Reminder(startTime, endTime, interval, activeDays)
    ↓
Calculate time slots
    startTime = 09:00
    endTime = 21:00
    interval = 60 minutes
    ↓
Generate times: [09:00, 10:00, 11:00, ..., 21:00]
    ↓
For next 7 days:
    ↓
Filter by activeDays (Mon-Fri)
    ↓
Create AlarmSettings for each time
    ↓
Schedule with system
```

### Unique ID Generation

```
Example Reminder:
- ID: 5
- Day 0 (Today), Alarm 0 (9:00 AM)
  → AlarmID = 5 × 10000 + 0 × 100 + 0 = 50000

- ID: 5
- Day 1 (Tomorrow), Alarm 3 (12:00 PM)
  → AlarmID = 5 × 10000 + 1 × 100 + 3 = 50103

- ID: 5
- Day 6 (Next Week), Alarm 12 (9:00 PM)
  → AlarmID = 5 × 10000 + 6 × 100 + 12 = 50612

Range per reminder: 50000-50699 (700 slots)
```

## Error Handling Strategy

```
┌─────────────────────────────────────────────────────────────────┐
│                      Error Handling                              │
│                                                                   │
│  Level 1: Data Layer                                            │
│  ├─ Database errors → Rollback transaction                      │
│  └─ Model validation → Return error to caller                   │
│                                                                   │
│  Level 2: Service Layer                                         │
│  ├─ Alarm scheduling fails → Retry + Log                        │
│  ├─ Permission denied → Prompt user                             │
│  └─ Ringer mode check fails → Default to normal                 │
│                                                                   │
│  Level 3: Business Logic                                        │
│  ├─ Provider catches exceptions                                 │
│  ├─ Logs errors                                                 │
│  └─ Returns error state to UI                                   │
│                                                                   │
│  Level 4: UI Layer                                              │
│  ├─ Shows SnackBar with error message                           │
│  ├─ Allows retry                                                │
│  └─ Graceful degradation                                        │
└─────────────────────────────────────────────────────────────────┘
```

## Security Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     Security Layers                              │
│                                                                   │
│  1. Operating System                                            │
│     ├─ App Sandbox (Android/iOS)                                │
│     ├─ Permission System                                        │
│     └─ Process Isolation                                        │
│                                                                   │
│  2. Application                                                  │
│     ├─ Local Storage Only                                       │
│     ├─ No Network Communication                                 │
│     ├─ Input Validation                                         │
│     └─ SQL Injection Prevention (Parameterized Queries)         │
│                                                                   │
│  3. Data                                                         │
│     ├─ Encrypted at rest (OS-level)                            │
│     ├─ No sensitive data stored                                 │
│     └─ Cleared on uninstall                                     │
└─────────────────────────────────────────────────────────────────┘
```

## Performance Considerations

### Database Optimization

```
Query Optimization:
- Indexed primary keys
- Efficient WHERE clauses
- Limited result sets
- Batch operations where possible

Connection Management:
- Singleton pattern for database instance
- Proper connection lifecycle
- Transaction support
```

### UI Performance

```
Widget Optimization:
- Const constructors where possible
- Minimal rebuilds with Provider
- Lazy loading for lists
- Efficient list rendering (ListView.builder)

Memory Management:
- Dispose controllers properly
- Cancel subscriptions
- Clear caches when appropriate
```

## Testing Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      Testing Pyramid                             │
│                                                                   │
│                    ┌────────────┐                               │
│                    │     E2E    │  Integration Tests             │
│                    └────────────┘  - Full flows                  │
│                 ┌──────────────────┐                            │
│                 │   Widget Tests   │  UI Component Tests         │
│                 └──────────────────┘  - Screen tests             │
│              ┌──────────────────────────┐                       │
│              │      Unit Tests          │  Logic Tests           │
│              │   - Models               │  - Models              │
│              │   - Services             │  - Services            │
│              │   - Providers            │  - Providers           │
│              └──────────────────────────┘                       │
└─────────────────────────────────────────────────────────────────┘
```

## Deployment Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        CI/CD Pipeline                            │
│                     (GitHub Actions)                             │
│                                                                   │
│  Trigger: Push / Pull Request                                   │
│     ↓                                                            │
│  Setup Flutter Environment                                      │
│     ↓                                                            │
│  Install Dependencies (flutter pub get)                         │
│     ↓                                                            │
│  Code Analysis (flutter analyze)                                │
│     ↓                                                            │
│  Run Tests (flutter test)                                       │
│     ↓                                                            │
│  Security Scan (CodeQL)                                         │
│     ↓                                                            │
│  Build APK (flutter build apk)                                  │
│     ↓                                                            │
│  Artifacts Ready for Deployment                                 │
└─────────────────────────────────────────────────────────────────┘
```

## Scalability Considerations

### Current Architecture Supports:
- ✅ 100+ reminders per user
- ✅ 700 alarms per reminder
- ✅ Efficient database queries
- ✅ Background execution

### Future Scaling Options:
- 🔄 Cloud sync for multi-device
- 🔄 Shared reminders between users
- 🔄 Analytics and usage tracking
- 🔄 Advanced scheduling algorithms

## Architecture Principles Applied

1. **Separation of Concerns**
   - Clear layer boundaries
   - Single responsibility per class
   - Minimal coupling

2. **SOLID Principles**
   - Single Responsibility
   - Open/Closed
   - Liskov Substitution
   - Interface Segregation
   - Dependency Inversion

3. **Clean Architecture**
   - Domain models independent of UI
   - Services abstracted from implementation
   - Testable components

4. **Design Patterns**
   - Singleton (Services)
   - Provider (State Management)
   - Repository (Data Access)
   - Factory (Object Creation)
   - Observer (State Updates)

---

This architecture provides a solid foundation for a maintainable, scalable, and secure interval-based alarm reminder application.
