import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:zobimed/models/reminder.dart'; // Import Reminder model
import 'package:zobimed/models/custom_alarm_sound.dart'; // Import CustomAlarmSound model

class AddReminderPage extends StatefulWidget {
  final Function(Reminder) onSave; // For adding new reminders
  final Reminder? existingReminder;
  final int? reminderIndex;
  final Function(int, Reminder)? onUpdate; // For updating existing reminders

  const AddReminderPage({
    super.key,
    required this.onSave,
    this.existingReminder,
    this.reminderIndex,
    this.onUpdate,
  });

  @override
  State<AddReminderPage> createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final TextEditingController _medicineNameController = TextEditingController();
  TimeOfDay? _selectedTime;
  String _selectedAlarmSound =
      'Bell'; // Default, will be overridden by prefs or existing reminder
  bool _isSaveButtonEnabled = false;

  List<CustomAlarmSound> _customAlarmSounds = [];
  final List<String> _builtInSounds = [
    'Bell',
    'Chime',
    'Alarm',
    'Morning Flower'
  ];
  static const String _customAlarmsStorageKey = 'zobimed_custom_alarms_v1';
  static const String _defaultAlarmSoundKey = 'zobimed_default_alarm_v1';

  @override
  void initState() {
    super.initState();
    _medicineNameController.addListener(_validateForm);
    _loadSoundPreferences(); // Load sounds and default preference

    if (widget.existingReminder != null) {
      _medicineNameController.text = widget.existingReminder!.medicineName;
      _selectedTime = widget.existingReminder!.reminderTime;
      // If editing, use the reminder's specific sound, otherwise default is already set by _loadSoundPreferences
      _selectedAlarmSound = widget.existingReminder!.alarmSound;
      _validateForm();
    }
    // If not editing, _selectedAlarmSound will be the loaded default or 'Bell'
    // and _validateForm will be called by _loadSoundPreferences if needed.
  }

  Future<void> _loadSoundPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    // Load custom sounds
    final List<String>? customSoundsJson =
        prefs.getStringList(_customAlarmsStorageKey);
    if (customSoundsJson != null) {
      _customAlarmSounds = customSoundsJson
          .map((jsonString) => CustomAlarmSound.fromJson(
              jsonDecode(jsonString) as Map<String, dynamic>))
          .toList();
    }

    // Load default sound preference only if not editing an existing reminder
    if (widget.existingReminder == null) {
      final String? savedDefaultSound = prefs.getString(_defaultAlarmSoundKey);
      if (savedDefaultSound != null) {
        // Ensure the saved default sound is valid (exists in built-in or custom)
        List<String> allAvailableSounds = [
          ..._builtInSounds,
          ..._customAlarmSounds.map((s) => s.name)
        ];
        if (allAvailableSounds.contains(savedDefaultSound)) {
          _selectedAlarmSound = savedDefaultSound;
        } else {
          _selectedAlarmSound =
              'Bell'; // Fallback if saved default is no longer valid
        }
      } else {
        _selectedAlarmSound = 'Bell'; // Fallback if no default is saved
      }
    }
    // We need to call setState here to update the dropdown if sounds were loaded
    // or if the default sound was applied.
    if (mounted) {
      setState(() {
        // This will trigger a rebuild with the potentially updated _selectedAlarmSound
        // and the loaded _customAlarmSounds for the dropdown items.
      });
    }
  }

  @override
  void dispose() {
    _medicineNameController.dispose();
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      _isSaveButtonEnabled =
          _medicineNameController.text.isNotEmpty && _selectedTime != null;
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

  void _submitReminder() {
    if (_isSaveButtonEnabled) {
      final reminderData = Reminder(
        medicineName: _medicineNameController.text,
        reminderTime: _selectedTime!,
        alarmSound: _selectedAlarmSound,
      );

      if (widget.existingReminder != null &&
          widget.onUpdate != null &&
          widget.reminderIndex != null) {
        // Editing existing reminder
        widget.onUpdate!(widget.reminderIndex!, reminderData);
      } else {
        // Adding new reminder
        widget.onSave(reminderData);
      }
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
        title: Text(
          widget.existingReminder == null ? 'Add Reminder' : 'Edit Reminder',
          style: const TextStyle(
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
              Colors.white, // White
            ],
          ),
        ),
        child: SingleChildScrollView(
          // Wrap with SingleChildScrollView
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
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
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
                                prefixIcon: Icon(Icons.access_time,
                                    color: Colors.blue.shade700),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade100,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
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
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            prefixIcon: Icon(Icons.volume_up,
                                color: Colors.blue.shade700),
                          ),
                          value: _selectedAlarmSound,
                          // Ensure the value exists in the items list, otherwise Flutter throws an error.
                          // This check is important if _selectedAlarmSound might be a value not in the combined list.
                          // However, _loadSoundPreferences should handle setting a valid default.
                          items: [
                            ..._builtInSounds.map((sound) => DropdownMenuItem(
                                  value: sound,
                                  child: Text(sound),
                                )),
                            ..._customAlarmSounds
                                .map((sound) => DropdownMenuItem(
                                      value: sound.name,
                                      child: Text(sound.name),
                                    )),
                          ]
                              .toSet()
                              .toList(), // .toSet().toList() to remove potential duplicates if a custom sound has same name as built-in
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedAlarmSound = newValue;
                              });
                            }
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
                          ? [
                              const Color(0xFF2196F3),
                              const Color(0xFF00BCD4)
                            ] // Blue to Teal
                          : [
                              Colors.grey.shade400,
                              Colors.grey.shade600
                            ], // Grey when disabled
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  child: ElevatedButton.icon(
                    onPressed: _isSaveButtonEnabled ? _submitReminder : null,
                    icon: Icon(
                        widget.existingReminder == null
                            ? Icons.save
                            : Icons.check,
                        color: Colors.white),
                    label: Text(
                      widget.existingReminder == null
                          ? 'Save Reminder'
                          : 'Update Reminder',
                      style: const TextStyle(
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
      ),
    );
  }
}
