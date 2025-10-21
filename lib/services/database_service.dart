import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/reminder.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('reminders.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE reminders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        startTime TEXT NOT NULL,
        endTime TEXT NOT NULL,
        intervalMinutes INTEGER NOT NULL,
        activeDays TEXT NOT NULL,
        isEnabled INTEGER NOT NULL,
        soundPath TEXT NOT NULL,
        snoozeCount INTEGER DEFAULT 0,
        maxSnoozes INTEGER DEFAULT 3,
        gradualVolume INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL,
        lastTriggered TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE alarm_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        reminderId INTEGER NOT NULL,
        triggeredAt TEXT NOT NULL,
        dismissedAt TEXT,
        snoozed INTEGER DEFAULT 0,
        FOREIGN KEY (reminderId) REFERENCES reminders (id) ON DELETE CASCADE
      )
    ''');
  }

  Future<int> createReminder(Reminder reminder) async {
    try {
      print('DB Service: Getting database instance');
      final db = await database;
      print('DB Service: Database instance obtained');
      
      final reminderMap = reminder.toMap();
      print('DB Service: Reminder converted to map: $reminderMap');
      
      final id = await db.insert('reminders', reminderMap);
      print('DB Service: Reminder inserted with ID: $id');
      
      return id;
    } catch (e, stackTrace) {
      print('DB Service: Error creating reminder: $e');
      print('DB Service: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<Reminder?> getReminder(int id) async {
    final db = await database;
    final maps = await db.query(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Reminder.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Reminder>> getAllReminders() async {
    final db = await database;
    final maps = await db.query('reminders', orderBy: 'createdAt DESC');
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<List<Reminder>> getEnabledReminders() async {
    final db = await database;
    final maps = await db.query(
      'reminders',
      where: 'isEnabled = ?',
      whereArgs: [1],
      orderBy: 'createdAt DESC',
    );
    return maps.map((map) => Reminder.fromMap(map)).toList();
  }

  Future<int> updateReminder(Reminder reminder) async {
    final db = await database;
    return await db.update(
      'reminders',
      reminder.toMap(),
      where: 'id = ?',
      whereArgs: [reminder.id],
    );
  }

  Future<int> deleteReminder(int id) async {
    final db = await database;
    return await db.delete(
      'reminders',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> logAlarmTrigger(int reminderId, DateTime triggeredAt) async {
    final db = await database;
    await db.insert('alarm_history', {
      'reminderId': reminderId,
      'triggeredAt': triggeredAt.toIso8601String(),
      'snoozed': 0,
    });
  }

  Future<void> logAlarmDismiss(int historyId, DateTime dismissedAt) async {
    final db = await database;
    await db.update(
      'alarm_history',
      {'dismissedAt': dismissedAt.toIso8601String()},
      where: 'id = ?',
      whereArgs: [historyId],
    );
  }

  Future<void> logAlarmSnooze(int historyId) async {
    final db = await database;
    await db.update(
      'alarm_history',
      {'snoozed': 1},
      where: 'id = ?',
      whereArgs: [historyId],
    );
  }

  Future<Map<String, dynamic>> getReminderStats(int reminderId) async {
    final db = await database;
    final result = await db.rawQuery('''
      SELECT 
        COUNT(*) as totalTriggered,
        SUM(CASE WHEN dismissedAt IS NOT NULL THEN 1 ELSE 0 END) as dismissed,
        SUM(CASE WHEN snoozed = 1 THEN 1 ELSE 0 END) as snoozed
      FROM alarm_history
      WHERE reminderId = ?
    ''', [reminderId]);

    return result.first;
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
