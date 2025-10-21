import 'dart:async';
import 'package:alarm/alarm.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import '../models/reminder.dart';

class AlarmService {
  static final AlarmService instance = AlarmService._init();
  AlarmService._init();

  Future<void> initialize() async {
    await Alarm.init();
  }

  Future<RingerModeStatus> getCurrentRingerMode() async {
    try {
      return await SoundMode.ringerModeStatus;
    } catch (e) {
      print('Error getting ringer mode: $e');
      return RingerModeStatus.normal;
    }
  }

  Future<void> scheduleAlarm({
    required int alarmId,
    required DateTime alarmTime,
    required Reminder reminder,
  }) async {
    final ringerMode = await getCurrentRingerMode();
    
    // Determine if we should play sound based on ringer mode
    final shouldPlaySound = ringerMode == RingerModeStatus.normal;
    
    final alarmSettings = AlarmSettings(
      id: alarmId,
      dateTime: alarmTime,
      assetAudioPath: shouldPlaySound ? reminder.soundPath : 'assets/sounds/silent.mp3',
      loopAudio: true,
      vibrate: true,
      volume: shouldPlaySound ? (reminder.gradualVolume ? 0.5 : 1.0) : 0.0,
      fadeDuration: reminder.gradualVolume ? 30.0 : 0.0,
      notificationTitle: reminder.name,
      notificationBody: 'Time for your reminder!',
      enableNotificationOnKill: true,
      androidFullScreenIntent: true,
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  Future<void> scheduleReminderAlarms(Reminder reminder) async {
    if (!reminder.isEnabled || reminder.id == null) return;

    // Cancel existing alarms for this reminder
    await cancelReminderAlarms(reminder.id!);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Schedule alarms for the next 7 days
    for (int dayOffset = 0; dayOffset < 7; dayOffset++) {
      final date = today.add(Duration(days: dayOffset));
      final weekday = date.weekday;

      if (reminder.activeDays.contains(weekday)) {
        final alarms = reminder.getScheduledAlarmsForDay(date);
        
        for (int i = 0; i < alarms.length; i++) {
          final alarmTime = alarms[i];
          if (alarmTime.isAfter(now)) {
            // Generate unique alarm ID: reminderId * 10000 + dayOffset * 100 + alarmIndex
            final alarmId = reminder.id! * 10000 + dayOffset * 100 + i;
            await scheduleAlarm(
              alarmId: alarmId,
              alarmTime: alarmTime,
              reminder: reminder,
            );
          }
        }
      }
    }
  }

  Future<void> cancelReminderAlarms(int reminderId) async {
    // Cancel all alarms for this reminder (up to 700 possible alarms per reminder)
    for (int i = 0; i < 700; i++) {
      final alarmId = reminderId * 10000 + i;
      if (await Alarm.isRinging(alarmId)) {
        await Alarm.stop(alarmId);
      }
    }
  }

  Future<void> stopAlarm(int alarmId) async {
    await Alarm.stop(alarmId);
  }

  Future<void> snoozeAlarm(int alarmId, int snoozeMinutes) async {
    await Alarm.stop(alarmId);
    
    // Schedule a new alarm for snooze time
    final snoozeTime = DateTime.now().add(Duration(minutes: snoozeMinutes));
    
    // Get the current alarm settings to preserve them
    final alarmSettings = AlarmSettings(
      id: alarmId + 1000000, // Different ID for snooze
      dateTime: snoozeTime,
      assetAudioPath: 'assets/sounds/default_alarm.mp3',
      loopAudio: true,
      vibrate: true,
      volume: 1.0,
      notificationTitle: 'Snoozed Reminder',
      notificationBody: 'Your reminder is back!',
      enableNotificationOnKill: true,
      androidFullScreenIntent: true,
    );

    await Alarm.set(alarmSettings: alarmSettings);
  }

  Stream<AlarmSettings> get alarmStream => Alarm.ringStream.stream;

  Future<bool> isAlarmRinging(int alarmId) async {
    return await Alarm.isRinging(alarmId);
  }

  Future<void> testAlarm(String soundPath) async {
    final testAlarmSettings = AlarmSettings(
      id: 999999,
      dateTime: DateTime.now().add(const Duration(seconds: 2)),
      assetAudioPath: soundPath,
      loopAudio: false,
      vibrate: true,
      volume: 0.8,
      notificationTitle: 'Test Alarm',
      notificationBody: 'This is a test',
      enableNotificationOnKill: false,
      androidFullScreenIntent: true,
    );

    await Alarm.set(alarmSettings: testAlarmSettings);
  }
}
