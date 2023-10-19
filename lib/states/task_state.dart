import 'package:flutter/material.dart';
import 'package:today/services/analytics_service.dart';
import 'package:today/services/mixpanel_service.dart';
import 'package:today/states/date_state.dart';
import 'package:today/models/my_task.dart';
import 'package:today/states/list_state/list_state.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/utils/date_time_utils.dart';

class TaskState extends ChangeNotifier {
  final selectedTask = ValueNotifier<MyTask>(MyTask(title: ''));
  final listState = getIt<ListState>();
  final dateState = getIt<DateState>();

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
      updateStartTime(dateState.selectedDate.value, selectedTask.value.startTime!.hour, selectedTask.value.startTime!.minute);
    }
    if (selectedTask.value.endTime != null) {
      updateEndTime(dateState.selectedDate.value, selectedTask.value.endTime!.hour, selectedTask.value.endTime!.minute);
    }
  }

  Future toggleTaskCompleted(MyTask task) async {
    task.isCompleted = !task.isCompleted;
    listState.selectedList.notifyListeners(); //so the phone screen reflects the state change
    await Future.delayed(const Duration(milliseconds: 900));

    await listState.updateListByTaskIsCompleted(task);

    if (task.isCompleted) {
      await AnalyticsService().updateUserStatOnCompleted(task);
    }
  }
}
