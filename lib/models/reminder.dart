import 'package:intl/intl.dart';

class Reminder {
  final int? id;
  final String name;
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format
  final int intervalMinutes;
  final List<int> activeDays; // 1=Monday, 7=Sunday
  final bool isEnabled;
  final String soundPath;
  final int snoozeCount;
  final int maxSnoozes;
  final bool gradualVolume;
  final DateTime createdAt;
  final DateTime? lastTriggered;

  Reminder({
    this.id,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.intervalMinutes,
    required this.activeDays,
    this.isEnabled = true,
    this.soundPath = 'assets/sounds/default_alarm.mp3',
    this.snoozeCount = 0,
    this.maxSnoozes = 3,
    this.gradualVolume = false,
    required this.createdAt,
    this.lastTriggered,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'startTime': startTime,
      'endTime': endTime,
      'intervalMinutes': intervalMinutes,
      'activeDays': activeDays.join(','),
      'isEnabled': isEnabled ? 1 : 0,
      'soundPath': soundPath,
      'snoozeCount': snoozeCount,
      'maxSnoozes': maxSnoozes,
      'gradualVolume': gradualVolume ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'lastTriggered': lastTriggered?.toIso8601String(),
    };
  }

  factory Reminder.fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'] as int?,
      name: map['name'] as String,
      startTime: map['startTime'] as String,
      endTime: map['endTime'] as String,
      intervalMinutes: map['intervalMinutes'] as int,
      activeDays: (map['activeDays'] as String)
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) => int.parse(s))
          .toList(),
      isEnabled: map['isEnabled'] == 1,
      soundPath: map['soundPath'] as String,
      snoozeCount: map['snoozeCount'] as int? ?? 0,
      maxSnoozes: map['maxSnoozes'] as int? ?? 3,
      gradualVolume: map['gradualVolume'] == 1,
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastTriggered: map['lastTriggered'] != null
          ? DateTime.parse(map['lastTriggered'] as String)
          : null,
    );
  }

  Reminder copyWith({
    int? id,
    String? name,
    String? startTime,
    String? endTime,
    int? intervalMinutes,
    List<int>? activeDays,
    bool? isEnabled,
    String? soundPath,
    int? snoozeCount,
    int? maxSnoozes,
    bool? gradualVolume,
    DateTime? createdAt,
    DateTime? lastTriggered,
  }) {
    return Reminder(
      id: id ?? this.id,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      intervalMinutes: intervalMinutes ?? this.intervalMinutes,
      activeDays: activeDays ?? this.activeDays,
      isEnabled: isEnabled ?? this.isEnabled,
      soundPath: soundPath ?? this.soundPath,
      snoozeCount: snoozeCount ?? this.snoozeCount,
      maxSnoozes: maxSnoozes ?? this.maxSnoozes,
      gradualVolume: gradualVolume ?? this.gradualVolume,
      createdAt: createdAt ?? this.createdAt,
      lastTriggered: lastTriggered ?? this.lastTriggered,
    );
  }

  String getNextAlarmTime() {
    final now = DateTime.now();
    final currentDay = now.weekday;
    
    if (!activeDays.contains(currentDay) || !isEnabled) {
      return 'Not scheduled';
    }

    final startParts = startTime.split(':');
    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    
    final endParts = endTime.split(':');
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);
    
    final startDateTime = DateTime(now.year, now.month, now.day, startHour, startMinute);
    final endDateTime = DateTime(now.year, now.month, now.day, endHour, endMinute);
    
    if (now.isBefore(startDateTime)) {
      return DateFormat('HH:mm').format(startDateTime);
    } else if (now.isAfter(endDateTime)) {
      // Find next active day
      for (int i = 1; i <= 7; i++) {
        final nextDay = (currentDay + i) % 7;
        final adjustedDay = nextDay == 0 ? 7 : nextDay;
        if (activeDays.contains(adjustedDay)) {
          final nextDate = now.add(Duration(days: i));
          final nextAlarm = DateTime(nextDate.year, nextDate.month, nextDate.day, startHour, startMinute);
          return DateFormat('EEE HH:mm').format(nextAlarm);
        }
      }
      return 'Not scheduled';
    } else {
      // Find next interval within today
      var nextAlarm = startDateTime;
      while (nextAlarm.isBefore(now)) {
        nextAlarm = nextAlarm.add(Duration(minutes: intervalMinutes));
      }
      
      if (nextAlarm.isAfter(endDateTime)) {
        // Next alarm is tomorrow
        for (int i = 1; i <= 7; i++) {
          final nextDay = (currentDay + i) % 7;
          final adjustedDay = nextDay == 0 ? 7 : nextDay;
          if (activeDays.contains(adjustedDay)) {
            final nextDate = now.add(Duration(days: i));
            final nextAlarmDate = DateTime(nextDate.year, nextDate.month, nextDate.day, startHour, startMinute);
            return DateFormat('EEE HH:mm').format(nextAlarmDate);
          }
        }
        return 'Not scheduled';
      }
      
      return DateFormat('HH:mm').format(nextAlarm);
    }
  }

  List<DateTime> getScheduledAlarmsForDay(DateTime date) {
    final startParts = startTime.split(':');
    final startHour = int.parse(startParts[0]);
    final startMinute = int.parse(startParts[1]);
    
    final endParts = endTime.split(':');
    final endHour = int.parse(endParts[0]);
    final endMinute = int.parse(endParts[1]);
    
    final startDateTime = DateTime(date.year, date.month, date.day, startHour, startMinute);
    final endDateTime = DateTime(date.year, date.month, date.day, endHour, endMinute);
    
    final alarms = <DateTime>[];
    var currentAlarm = startDateTime;
    
    while (currentAlarm.isBefore(endDateTime) || currentAlarm.isAtSameMomentAs(endDateTime)) {
      alarms.add(currentAlarm);
      currentAlarm = currentAlarm.add(Duration(minutes: intervalMinutes));
    }
    
    return alarms;
  }
}
