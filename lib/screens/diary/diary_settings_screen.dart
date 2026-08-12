import 'package:flutter/material.dart';

class DiarySettingsScreen extends StatefulWidget {
  const DiarySettingsScreen({super.key});

  @override
  State<DiarySettingsScreen> createState() =>
      _DiarySettingsScreenState();
}

class _DiarySettingsScreenState
    extends State<DiarySettingsScreen> {
  bool reminderEnabled = false;

  TimeOfDay reminderTime = const TimeOfDay(
    hour: 18,
    minute: 0,
  );

  // --------------------------------------------------
  // REMINDER TIME PICKER
  // --------------------------------------------------

  Future<void> _selectReminderTime() async {
    if (!reminderEnabled) {
      return;
    }

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: reminderTime,
      helpText: 'Select reminder time',
      cancelText: 'Cancel',
      confirmText: 'OK',
    );

    if (picked != null && mounted) {
      setState(() {
        reminderTime = picked;
      });
    }
  }

  // --------------------------------------------------
  // FORMAT TIME
  // --------------------------------------------------

  String _formatTime(TimeOfDay time) {
    final int hour = time.hourOfPeriod == 0
        ? 12
        : time.hourOfPeriod;

    final String minute =
        time.minute.toString().padLeft(2, '0');

    final String period =
        time.period == DayPeriod.am ? 'AM' : 'PM';

    return '$hour:$minute $period';
  }

  // --------------------------------------------------
  // SAVE
  // --------------------------------------------------

  void _saveSettings() {
    Navigator.pop(context);
  }

  // --------------------------------------------------
  // BUILD
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Diary Settings'),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // --------------------------------------------------
          // REMINDER TOGGLE
          // --------------------------------------------------

          Card(
            child: SwitchListTile(
              contentPadding:
                  const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),

              title: const Text(
                'Diary Reminder',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              subtitle: Text(
                reminderEnabled
                    ? 'Reminder is enabled'
                    : 'Reminder is disabled',
              ),

              value: reminderEnabled,

              onChanged: (bool value) {
                setState(() {
                  reminderEnabled = value;
                });
              },
            ),
          ),

          const SizedBox(height: 12),

          // --------------------------------------------------
          // REMINDER TIME
          // --------------------------------------------------

          Card(
            child: ListTile(
              enabled: reminderEnabled,

              leading: Icon(
                Icons.access_time,
                color: reminderEnabled
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                    : Colors.grey,
              ),

              title: const Text(
                'Reminder Time',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),

              subtitle: Text(
                reminderEnabled
                    ? _formatTime(reminderTime)
                    : 'Turn on reminder to select time',
              ),

              trailing: Icon(
                Icons.schedule,
                color: reminderEnabled
                    ? Theme.of(context)
                        .colorScheme
                        .primary
                    : Colors.grey,
              ),

              onTap: reminderEnabled
                  ? _selectReminderTime
                  : null,
            ),
          ),

          const SizedBox(height: 28),

          // --------------------------------------------------
          // SAVE BUTTON
          // --------------------------------------------------

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(
                Icons.save_outlined,
              ),
              label: const Text(
                'Save',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}