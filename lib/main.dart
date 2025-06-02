import 'package:flutter/material.dart';
import 'package:zobimed/settings_page.dart';
import 'package:zobimed/add_reminder_page.dart';
import 'package:zobimed/models/reminder.dart'; // Import the Reminder model

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZOBIMED',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto', // A clean, accessible font
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Reminder> _reminders = [];

  void _addReminder(Reminder newReminder) {
    setState(() {
      _reminders.add(newReminder);
      // Sort reminders by time (optional, but good for UX)
      _reminders
          .sort((a, b) => _compareTimeOfDay(a.reminderTime, b.reminderTime));
    });
  }

  void _updateReminder(int index, Reminder updatedReminder) {
    setState(() {
      _reminders[index] = updatedReminder;
      // Sort reminders by time (optional, but good for UX)
      _reminders
          .sort((a, b) => _compareTimeOfDay(a.reminderTime, b.reminderTime));
    });
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    if (a.hour != b.hour) {
      return a.hour.compareTo(b.hour);
    }
    return a.minute.compareTo(b.minute);
  }

  void _clearAllReminders() {
    setState(() {
      _reminders.clear();
    });
    // Optionally, show a SnackBar or Toast
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('All reminders cleared.'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _deleteReminder(BuildContext dialogContext, int index) {
    // Close the modal bottom sheet first
    Navigator.pop(
        dialogContext); // dialogContext is the context of the modal bottom sheet

    showDialog(
      context: context, // Use the HomePage context for the dialog
      builder: (BuildContext alertContext) {
        return AlertDialog(
          title: const Text('Delete Reminder'),
          content: const Text('Are you sure you want to delete this reminder?'),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(alertContext).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  _reminders.removeAt(index);
                });
                Navigator.of(alertContext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _navigateToEditReminder(Reminder reminder, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddReminderPage(
          onSave:
              _addReminder, // This will be used if a new reminder is somehow saved from edit mode
          existingReminder: reminder,
          reminderIndex: index,
          onUpdate: _updateReminder,
        ),
      ),
    );
  }

  void _showReminderOptions(
      BuildContext bottomSheetContext, Reminder reminder, int index) {
    showModalBottomSheet(
      context: context, // Use HomePage context for the bottom sheet
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        // sheetContext is the context of the modal content
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 10,
                offset: const Offset(0, -3), // changes position of shadow
              ),
            ],
          ),
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text('Edit Reminder'),
                onTap: () {
                  Navigator.pop(sheetContext); // Close the bottom sheet
                  _navigateToEditReminder(reminder, index);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete, color: Colors.red.shade700),
                title: Text('Delete Reminder',
                    style: TextStyle(color: Colors.red.shade700)),
                onTap: () {
                  // Pass sheetContext to _deleteReminder so it can pop itself before showing dialog
                  _deleteReminder(sheetContext, index);
                },
              ),
              const SizedBox(height: 10), // For some padding at the bottom
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leadingWidth: 200,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade700,
                radius: 18,
                child: const Icon(Icons.medical_services,
                    color: Colors.white, size: 20),
              ),
              const SizedBox(width: 8),
              const Text(
                'ZOBIMED',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black54),
            onPressed: () async {
              // Make onPressed async
              final result = await Navigator.push(
                // await the result
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );

              if (result == true) {
                _clearAllReminders();
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD), // Light Blue
              Colors.white, // White
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Upcoming Reminders',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Stay on track with your medications',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
              Expanded(
                child: _reminders.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              radius: 40,
                              child: Icon(
                                Icons.medical_services,
                                color: Colors.blue.shade700,
                                size: 40,
                              ),
                            ),
                            const SizedBox(height: 24),
                            const Text(
                              'No reminders yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Add your first medicine reminder to get started',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 48),
                            Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF2196F3), // Blue
                                    Color(0xFF00BCD4), // Teal
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddReminderPage(
                                        onSave: _addReminder,
                                      ),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                  ),
                                ),
                                child: const Text(
                                  'Add First Reminder',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _reminders.length,
                        itemBuilder: (context, index) {
                          final reminder = _reminders[index];
                          return ReminderCard(
                            reminder: reminder,
                            index: index,
                            onCardTap: (tappedReminder, tappedIndex) {
                              _showReminderOptions(
                                  context, tappedReminder, tappedIndex);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _reminders.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddReminderPage(
                      onSave: _addReminder,
                      // No existingReminder, reminderIndex, or onUpdate for a new reminder
                    ),
                  ),
                );
              },
              label: const Text(
                'Add Reminder',
                style:
                    TextStyle(color: Colors.white), // Set text color to white
              ),
              icon: const Icon(
                Icons.add,
                color: Colors.white, // Set icon color to white for consistency
              ),
              backgroundColor: Colors.blue.shade700,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0)),
            )
          : null, // Hide FAB if no reminders exist
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class ReminderCard extends StatelessWidget {
  final Reminder reminder;
  final int index;
  final Function(Reminder, int) onCardTap;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.index,
    required this.onCardTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onCardTap(reminder, index),
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                radius: 25,
                child: Icon(
                  Icons.medication,
                  color: Colors.blue.shade700,
                  size: 25,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reminder.medicineName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${reminder.reminderTime.format(context)} - ${reminder.alarmSound}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
              // Replaced IconButton with GestureDetector on the whole card
              // Icon(Icons.more_vert, color: Colors.black54), // Optional: keep if you want a visual cue
            ],
          ),
        ),
      ),
    );
  }
}
