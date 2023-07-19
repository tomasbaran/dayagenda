import 'package:flutter/material.dart';
import 'package:today/managers/list_manager.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/utils/date_time_utils.dart';

class MyTask extends ChangeNotifier {
  DateTime? startTime;
  DateTime? endTime;
  String title;
  bool isCompleted;
  int? key;
  MyTask({
    this.startTime,
    this.endTime,
    this.key,
    required this.title,
    this.isCompleted = false,
  });
  final taskManager = getIt<ListManager>();

  @override
  String toString() {
    return '\n[$key] $title: $isCompleted; $startTime';
  }

  Future toggleCompleted() async {
    isCompleted = !isCompleted;
    taskManager.selectedList.notifyListeners();
    await Future.delayed(const Duration(milliseconds: 900));
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
