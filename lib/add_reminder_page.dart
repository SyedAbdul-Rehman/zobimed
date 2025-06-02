import 'package:flutter/material.dart';
import 'package:zobimed/models/reminder.dart'; // Import Reminder model

class AddReminderPage extends StatefulWidget {
  final Function(Reminder) onSave;

  const AddReminderPage({super.key, required this.onSave});

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final TextEditingController _medicineNameController = TextEditingController();
  TimeOfDay? _selectedTime;
  String _selectedAlarmSound = 'Bell';
  bool _isSaveButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    _medicineNameController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isSaveButtonEnabled = _medicineNameController.text.isNotEmpty && _selectedTime != null;
    });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
        _validateForm();
      });
    }
  }

  void _saveReminder() {
    if (_isSaveButtonEnabled) {
      final newReminder = Reminder(
        medicineName: _medicineNameController.text,
        reminderTime: _selectedTime!,
        alarmSound: _selectedAlarmSound,
      );
      widget.onSave(newReminder);
      Navigator.pop(context); // Go back to HomePage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Add Reminder',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD), // Light Blue
              Colors.white,      // White
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Medicine Name
                      const Text(
                        'Medicine Name *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _medicineNameController,
                        decoration: InputDecoration(
                          hintText: 'e.g., Vitamin C, Aspirin',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Reminder Time
                      const Text(
                        'Reminder Time *',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: () => _selectTime(context),
                        child: AbsorbPointer(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: _selectedTime == null
                                  ? '--:-- --'
                                  : _selectedTime!.format(context),
                              prefixIcon: Icon(Icons.access_time, color: Colors.blue.shade700),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Alarm Sound
                      const Text(
                        'Alarm Sound (Optional)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          prefixIcon: Icon(Icons.volume_up, color: Colors.blue.shade700),
                        ),
                        value: _selectedAlarmSound,
                        items: const [
                          DropdownMenuItem(value: 'Bell', child: Text('Bell')),
                          DropdownMenuItem(value: 'Chime', child: Text('Chime')),
                          DropdownMenuItem(value: 'Alarm', child: Text('Alarm')),
                        ],
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedAlarmSound = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              // Save Reminder Button
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isSaveButtonEnabled
                        ? [const Color(0xFF2196F3), const Color(0xFF00BCD4)] // Blue to Teal
                        : [Colors.grey.shade400, Colors.grey.shade600], // Grey when disabled
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(30.0),
                ),
                child: ElevatedButton.icon(
                  onPressed: _isSaveButtonEnabled ? _saveReminder : null,
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Save Reminder',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
