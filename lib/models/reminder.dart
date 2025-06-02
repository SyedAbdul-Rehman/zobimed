import 'package:flutter/material.dart';

class Reminder {
  final String medicineName;
  final TimeOfDay reminderTime;
  final String alarmSound;

  Reminder({
    required this.medicineName,
    required this.reminderTime,
    this.alarmSound = 'Bell',
  });

  // Method to convert a Reminder instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'medicineName': medicineName,
      'reminderTime_hour': reminderTime.hour,
      'reminderTime_minute': reminderTime.minute,
      'alarmSound': alarmSound,
    };
  }

  // Factory constructor to create a Reminder instance from a JSON map
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      medicineName: json['medicineName'] as String,
      reminderTime: TimeOfDay(
        hour: json['reminderTime_hour'] as int,
        minute: json['reminderTime_minute'] as int,
      ),
      alarmSound: json['alarmSound'] as String,
    );
  }
}
