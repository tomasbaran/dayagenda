import 'package:flutter/material.dart';

class MyTask {
  bool isDefault;
  String? listId;
  DateTime? startTime;
  DateTime? endTime;
  String title;
  bool isCompleted;
  ValueNotifier isBeingSnoozed = ValueNotifier<bool>(false);
  int? key;
  MyTask({
    this.listId,
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
      isDefault: isDefault,
      title: title, // String is immutable
      isCompleted: isCompleted, // Bool is immutable
      startTime: startTime,
      endTime: endTime,
      key: key,
    );
  }
}
