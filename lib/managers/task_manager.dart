import 'package:flutter/material.dart';
import 'package:today/managers/date_manager.dart';
import 'package:today/models/my_task.dart';
import 'package:today/managers/list_manager.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/utils/date_time_utils.dart';

class TaskManager {
  final selectedTask = ValueNotifier<MyTask>(MyTask(title: ''));
  final listManager = getIt<ListManager>();
  final dateManager = getIt<DateManager>();

  set selectTask(MyTask task) => selectedTask.value = task;
  unselectTask() {
    selectedTask.value = MyTask(title: '');
  }

  void updateTitle(String title) {
    selectedTask.value.title = title;
  }

  updateStartTime(
    DateTime date,
    int startTimeHours,
    int startTimeMinutes,
  ) {
    selectedTask.value.startTime = DateTimeUtils.mixDateAndTime(date: date, hours: startTimeHours, minutes: startTimeMinutes);
    debugPrint('updatedStartTime: ${selectedTask.value.startTime}');
  }

  updateEndTime(
    DateTime date,
    int endTimeHours,
    int endTimeMinutes,
  ) {
    selectedTask.value.endTime = DateTimeUtils.mixDateAndTime(date: date, hours: endTimeHours, minutes: endTimeMinutes);
    debugPrint('updatedStartTime: ${selectedTask.value.endTime}');
  }

  updateStartEndTimeToSelectedDate() {
    // when updating date of a task, also update its start/endTime date to selectedDate
    if (selectedTask.value.startTime != null) {
      updateStartTime(dateManager.selectedDate, selectedTask.value.startTime!.hour, selectedTask.value.startTime!.minute);
    }
    if (selectedTask.value.endTime != null) {
      updateEndTime(dateManager.selectedDate, selectedTask.value.endTime!.hour, selectedTask.value.endTime!.minute);
    }
  }
}
