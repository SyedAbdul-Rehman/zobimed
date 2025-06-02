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
}
