import 'package:flutter/material.dart';

class MyTask {
  DateTime? startTime;
  DateTime? endTime;
  String title;
  bool isCompleted;
  ValueNotifier isBeingSnoozed = ValueNotifier<bool>(false);
  bool isDefault;
  int? key;
  MyTask({
    this.isDefault = false,
    this.startTime,
    this.endTime,
    this.key,
    required this.title,
    this.isCompleted = false,
  });

  @override
  String toString() {
    return '\n[$key] $title: $isCompleted; $startTime';
  }

  MyTask clone() {
    return MyTask(
      title: title, // String is immutable
      isCompleted: isCompleted, // Bool is immutable
      startTime: startTime,
      endTime: endTime,
      key: key,
    );
  }
}
