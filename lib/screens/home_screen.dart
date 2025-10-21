import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/reminder_provider.dart';
import '../widgets/reminder_card.dart';
import 'add_edit_reminder_screen.dart';
import 'alarm_ring_screen.dart';
import '../services/alarm_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadReminders();
    _listenToAlarms();
  }

  Future<void> _loadReminders() async {
    await Provider.of<ReminderProvider>(context, listen: false).loadReminders();
  }

  void _listenToAlarms() {
    AlarmService.instance.alarmStream.listen((alarmSettings) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => AlarmRingScreen(
            alarmId: alarmSettings.id,
            title: alarmSettings.notificationTitle,
            body: alarmSettings.notificationBody,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interval Reminders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await Provider.of<ReminderProvider>(context, listen: false)
                  .refreshAlarms();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Alarms refreshed')),
              );
            },
          ),
        ],
      ),
      body: Consumer<ReminderProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.reminders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.alarm_add,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No reminders yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap + to create your first reminder',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadReminders,
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: provider.reminders.length,
              itemBuilder: (context, index) {
                final reminder = provider.reminders[index];
                return ReminderCard(
                  reminder: reminder,
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddEditReminderScreen(reminder: reminder),
                      ),
                    );
                    if (result == true) {
                      await _loadReminders();
                    }
                  },
                  onToggle: () async {
                    await provider.toggleReminder(reminder.id!);
                  },
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Delete Reminder'),
                        content: const Text(
                            'Are you sure you want to delete this reminder?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete',
                                style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      await provider.deleteReminder(reminder.id!);
                    }
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddEditReminderScreen(),
            ),
          );
          if (result == true) {
            await _loadReminders();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
