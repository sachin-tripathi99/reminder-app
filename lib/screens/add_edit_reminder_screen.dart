import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reminder.dart';
import '../providers/reminder_provider.dart';

class AddEditReminderScreen extends StatefulWidget {
  final Reminder? reminder;

  const AddEditReminderScreen({super.key, this.reminder});

  @override
  State<AddEditReminderScreen> createState() => _AddEditReminderScreenState();
}

class _AddEditReminderScreenState extends State<AddEditReminderScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;
  late int _intervalMinutes;
  late Set<int> _selectedDays;
  late bool _gradualVolume;

  final List<String> _intervalOptions = [
    '15 minutes',
    '30 minutes',
    '1 hour',
    '2 hours',
    '3 hours',
    '4 hours',
  ];

  final Map<String, int> _intervalValues = {
    '15 minutes': 15,
    '30 minutes': 30,
    '1 hour': 60,
    '2 hours': 120,
    '3 hours': 180,
    '4 hours': 240,
  };

  @override
  void initState() {
    super.initState();
    if (widget.reminder != null) {
      _nameController = TextEditingController(text: widget.reminder!.name);
      final startParts = widget.reminder!.startTime.split(':');
      _startTime = TimeOfDay(
        hour: int.parse(startParts[0]),
        minute: int.parse(startParts[1]),
      );
      final endParts = widget.reminder!.endTime.split(':');
      _endTime = TimeOfDay(
        hour: int.parse(endParts[0]),
        minute: int.parse(endParts[1]),
      );
      _intervalMinutes = widget.reminder!.intervalMinutes;
      _selectedDays = widget.reminder!.activeDays.toSet();
      _gradualVolume = widget.reminder!.gradualVolume;
    } else {
      _nameController = TextEditingController();
      _startTime = const TimeOfDay(hour: 9, minute: 0);
      _endTime = const TimeOfDay(hour: 21, minute: 0);
      _intervalMinutes = 60;
      _selectedDays = {1, 2, 3, 4, 5}; // Monday to Friday
      _gradualVolume = false;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );

    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  Future<void> _saveReminder() async {
    print('Save reminder called');
    
    if (!_formKey.currentState!.validate()) {
      print('Form validation failed');
      return;
    }

    if (_selectedDays.isEmpty) {
      print('No days selected');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one day')),
      );
      return;
    }

    print('Creating reminder object');
    final reminder = Reminder(
      id: widget.reminder?.id,
      name: _nameController.text.trim(),
      startTime: _formatTimeOfDay(_startTime),
      endTime: _formatTimeOfDay(_endTime),
      intervalMinutes: _intervalMinutes,
      activeDays: _selectedDays.toList()..sort(),
      isEnabled: widget.reminder?.isEnabled ?? true,
      soundPath: widget.reminder?.soundPath ?? 'assets/sounds/default_alarm.mp3',
      gradualVolume: _gradualVolume,
      createdAt: widget.reminder?.createdAt ?? DateTime.now(),
      snoozeCount: widget.reminder?.snoozeCount ?? 0,
      maxSnoozes: widget.reminder?.maxSnoozes ?? 3,
    );

    print('Reminder object created: ${reminder.name}');
    
    try {
      final provider = Provider.of<ReminderProvider>(context, listen: false);
      print('Provider obtained');
      
      if (widget.reminder != null) {
        print('Updating existing reminder');
        await provider.updateReminder(reminder);
      } else {
        print('Adding new reminder');
        await provider.addReminder(reminder);
      }

      print('Reminder saved successfully');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reminder saved successfully')),
        );
        Navigator.pop(context, true);
      }
    } catch (e, stackTrace) {
      print('Error saving reminder: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving reminder: $e')),
        );
      }
    }
  }

  Widget _buildDaySelector() {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(7, (index) {
        final dayNumber = index + 1;
        final isSelected = _selectedDays.contains(dayNumber);
        
        return FilterChip(
          label: Text(days[index]),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              if (selected) {
                _selectedDays.add(dayNumber);
              } else {
                _selectedDays.remove(dayNumber);
              }
            });
          },
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.reminder != null ? 'Edit Reminder' : 'Add Reminder'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveReminder,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Reminder Name',
                hintText: 'e.g., Drink Water, Take Medicine',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a name';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Time Range',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text('Start Time'),
                    subtitle: Text(_startTime.format(context)),
                    onTap: () => _selectTime(context, true),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ListTile(
                    title: const Text('End Time'),
                    subtitle: Text(_endTime.format(context)),
                    onTap: () => _selectTime(context, false),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: Colors.grey[300]!),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Interval',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _intervalMinutes,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              items: _intervalOptions.map((option) {
                return DropdownMenuItem(
                  value: _intervalValues[option],
                  child: Text(option),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _intervalMinutes = value;
                  });
                }
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Active Days',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            _buildDaySelector(),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Gradual Volume Increase'),
              subtitle: const Text('Volume increases gradually for gentler wake-up'),
              value: _gradualVolume,
              onChanged: (value) {
                setState(() {
                  _gradualVolume = value;
                });
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _saveReminder,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
              child: Text(
                widget.reminder != null ? 'Update Reminder' : 'Create Reminder',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
