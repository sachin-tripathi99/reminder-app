import 'package:flutter/foundation.dart';
import '../models/reminder.dart';
import '../services/database_service.dart';
import '../services/alarm_service.dart';

class ReminderProvider with ChangeNotifier {
  final DatabaseService _dbService = DatabaseService.instance;
  final AlarmService _alarmService = AlarmService.instance;
  
  List<Reminder> _reminders = [];
  bool _isLoading = false;

  List<Reminder> get reminders => _reminders;
  bool get isLoading => _isLoading;

  List<Reminder> get enabledReminders =>
      _reminders.where((r) => r.isEnabled).toList();

  Future<void> loadReminders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _reminders = await _dbService.getAllReminders();
    } catch (e) {
      print('Error loading reminders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addReminder(Reminder reminder) async {
    try {
      print('Provider: Creating reminder in database');
      final id = await _dbService.createReminder(reminder);
      print('Provider: Reminder created with ID: $id');
      
      final newReminder = reminder.copyWith(id: id);
      _reminders.insert(0, newReminder);
      
      if (newReminder.isEnabled) {
        print('Provider: Scheduling alarms for reminder');
        await _alarmService.scheduleReminderAlarms(newReminder);
        print('Provider: Alarms scheduled');
      }
      
      notifyListeners();
      print('Provider: Add reminder completed');
    } catch (e, stackTrace) {
      print('Error adding reminder: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<void> updateReminder(Reminder reminder) async {
    try {
      await _dbService.updateReminder(reminder);
      
      final index = _reminders.indexWhere((r) => r.id == reminder.id);
      if (index != -1) {
        _reminders[index] = reminder;
      }

      // Reschedule alarms
      if (reminder.id != null) {
        await _alarmService.cancelReminderAlarms(reminder.id!);
        if (reminder.isEnabled) {
          await _alarmService.scheduleReminderAlarms(reminder);
        }
      }
      
      notifyListeners();
    } catch (e) {
      print('Error updating reminder: $e');
      rethrow;
    }
  }

  Future<void> toggleReminder(int id) async {
    try {
      final index = _reminders.indexWhere((r) => r.id == id);
      if (index != -1) {
        final reminder = _reminders[index];
        final updatedReminder = reminder.copyWith(isEnabled: !reminder.isEnabled);
        await updateReminder(updatedReminder);
      }
    } catch (e) {
      print('Error toggling reminder: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(int id) async {
    try {
      await _dbService.deleteReminder(id);
      await _alarmService.cancelReminderAlarms(id);
      _reminders.removeWhere((r) => r.id == id);
      notifyListeners();
    } catch (e) {
      print('Error deleting reminder: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getReminderStats(int id) async {
    return await _dbService.getReminderStats(id);
  }

  Future<void> refreshAlarms() async {
    for (final reminder in enabledReminders) {
      if (reminder.id != null) {
        await _alarmService.scheduleReminderAlarms(reminder);
      }
    }
  }
}
