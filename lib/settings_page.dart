import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:path/path.dart' as p; // For basename

import 'package:zobimed/models/custom_alarm_sound.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _selectedDefaultAlarmSound = 'Bell'; // Will be loaded from prefs
  List<CustomAlarmSound> _customAlarmSounds = [];
  static const String _customAlarmsStorageKey = 'zobimed_custom_alarms_v1';
  static const String _defaultAlarmSoundKey = 'zobimed_default_alarm_v1';

  final List<String> _builtInSounds = [
    'Bell',
    'Chime',
    'Alarm',
    'Morning Flower'
  ];

  @override
  void initState() {
    super.initState();
    _loadCustomAlarmSounds();
    _loadDefaultAlarmSound();
  }

  Future<void> _loadDefaultAlarmSound() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedDefaultAlarmSound =
          prefs.getString(_defaultAlarmSoundKey) ?? 'Bell';
    });
  }

  Future<void> _saveDefaultAlarmSound(String soundName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_defaultAlarmSoundKey, soundName);
    setState(() {
      _selectedDefaultAlarmSound = soundName;
    });
  }

  Future<void> _loadCustomAlarmSounds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? soundsJson =
        prefs.getStringList(_customAlarmsStorageKey);
    if (soundsJson != null) {
      setState(() {
        _customAlarmSounds = soundsJson
            .map((jsonString) => CustomAlarmSound.fromJson(
                jsonDecode(jsonString) as Map<String, dynamic>))
            .toList();
      });
    }
  }

  Future<void> _saveCustomAlarmSounds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> soundsJson =
        _customAlarmSounds.map((sound) => jsonEncode(sound.toJson())).toList();
    await prefs.setStringList(_customAlarmsStorageKey, soundsJson);
  }

  Future<void> _pickAndAddCustomSound() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      // allowedExtensions: ['mp3', 'wav', 'aac'], // Optional: specify extensions
    );

    if (result != null && result.files.single.path != null) {
      String filePath = result.files.single.path!;
      String fileName = p
          .basenameWithoutExtension(filePath); // Get filename without extension

      // Prompt user for a display name, pre-fill with filename
      final TextEditingController nameController =
          TextEditingController(text: fileName);
      final soundName = await showDialog<String>(
        context: context,
        builder: (BuildContext dialogContext) {
          return AlertDialog(
            title: const Text('Name Your Sound'),
            content: TextField(
              controller: nameController,
              decoration: const InputDecoration(hintText: "Enter sound name"),
              autofocus: true,
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
              ),
              TextButton(
                child: const Text('Save'),
                onPressed: () {
                  if (nameController.text.trim().isNotEmpty) {
                    Navigator.of(dialogContext).pop(nameController.text.trim());
                  }
                },
              ),
            ],
          );
        },
      );

      if (soundName != null && soundName.isNotEmpty) {
        // Check for duplicate names (optional but good UX)
        if (_customAlarmSounds.any((s) => s.name == soundName) ||
            _builtInSounds.contains(soundName)) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content:
                  Text('A sound with the name "$soundName" already exists.')));
          return;
        }

        final newSound = CustomAlarmSound(name: soundName, filePath: filePath);
        setState(() {
          _customAlarmSounds.add(newSound);
        });
        await _saveCustomAlarmSounds();
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Custom sound "$soundName" added.')));
      }
    } else {
      // User canceled the picker or path was null
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('No file selected or path was invalid.')));
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
          'Settings',
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
              Colors.white, // White
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Section 1: Default Alarm Sound
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Default Alarm Sound',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Icon(Icons.volume_up, color: Colors.blue.shade700),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                            value: _selectedDefaultAlarmSound,
                            items: [
                              ..._builtInSounds.map((sound) => DropdownMenuItem(
                                    value: sound,
                                    child: Text(sound),
                                  )),
                              ..._customAlarmSounds
                                  .map((sound) => DropdownMenuItem(
                                        value: sound
                                            .name, // Use name as value, or filePath if preferred
                                        child: Text(sound.name),
                                      )),
                            ],
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                _saveDefaultAlarmSound(newValue);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Section: Manage Custom Sounds
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Manage Custom Sounds',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Potentially list custom sounds here with delete option
                    if (_customAlarmSounds.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // To disable scrolling within ListView
                        itemCount: _customAlarmSounds.length,
                        itemBuilder: (context, index) {
                          final sound = _customAlarmSounds[index];
                          return ListTile(
                            leading: const Icon(Icons.music_note,
                                color: Colors.teal),
                            title: Text(sound.name),
                            subtitle: Text(p.basename(sound.filePath),
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            trailing: IconButton(
                              icon: Icon(Icons.delete_outline,
                                  color: Colors.red.shade300),
                              onPressed: () async {
                                // Confirmation dialog before deleting
                                final confirmDelete = await showDialog<bool>(
                                  context: context,
                                  builder: (BuildContext dialogContext) =>
                                      AlertDialog(
                                    title: const Text('Delete Custom Sound?'),
                                    content: Text(
                                        'Are you sure you want to delete "${sound.name}"? This cannot be undone.'),
                                    actions: <Widget>[
                                      TextButton(
                                        child: const Text('Cancel'),
                                        onPressed: () =>
                                            Navigator.of(dialogContext)
                                                .pop(false),
                                      ),
                                      TextButton(
                                        style: TextButton.styleFrom(
                                            foregroundColor: Colors.red),
                                        child: const Text('Delete'),
                                        onPressed: () =>
                                            Navigator.of(dialogContext)
                                                .pop(true),
                                      ),
                                    ],
                                  ),
                                );
                                if (confirmDelete == true) {
                                  setState(() {
                                    // If this sound was the selected default, reset default
                                    if (_selectedDefaultAlarmSound ==
                                        sound.name) {
                                      _saveDefaultAlarmSound(
                                          'Bell'); // Reset to first built-in
                                    }
                                    _customAlarmSounds.removeAt(index);
                                  });
                                  await _saveCustomAlarmSounds();
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Custom sound "${sound.name}" deleted.')));
                                }
                              },
                            ),
                          );
                        },
                      ),
                    if (_customAlarmSounds.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          'No custom sounds added yet.',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Add Custom Sound'),
                        onPressed: _pickAndAddCustomSound,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section 2: Dark Mode
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.wb_sunny, color: Colors.orange.shade700),
                            const SizedBox(width: 16),
                            const Text(
                              'Dark Mode',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        Switch(
                          value: false, // Default: OFF
                          onChanged: (bool value) {
                            // No functionality yet
                          },
                          activeColor: Colors.blue.shade700,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Switch between light and dark themes',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section 3: Data Management
            Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              elevation: 4,
              color: Colors.red.shade50, // Soft red background
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.delete_forever, color: Colors.red.shade700),
                        const SizedBox(width: 16),
                        const Text(
                          'Clear All Reminders',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'This will permanently delete all your medicine reminders.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext dialogContext) {
                              return AlertDialog(
                                title: const Text('Clear All Reminders?'),
                                content: const Text(
                                    'This will permanently delete all your medicine reminders. Are you sure?'),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0)),
                                actions: <Widget>[
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(dialogContext)
                                          .pop(); // Close the dialog
                                    },
                                  ),
                                  ElevatedButton.icon(
                                    icon: const Icon(Icons.delete_forever,
                                        color: Colors.white),
                                    label: const Text('Delete All',
                                        style: TextStyle(color: Colors.white)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red.shade700,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(dialogContext)
                                          .pop(); // Close the dialog
                                      Navigator.pop(context,
                                          true); // Pop SettingsPage and return true
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red.shade700,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: const Text(
                          'Clear All',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Section 4: About App
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
                    const Text(
                      'About ZOBIMED',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Version 1.0.0',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your trusted companion for medication reminders.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
