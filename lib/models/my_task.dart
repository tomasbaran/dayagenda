import 'package:today/screens/tasks_screen/tasks_screen_manager.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/utils/date_time_utils.dart';

class MyTask {
  DateTime? startTime;
  DateTime? endTime;
  String title;
  bool completed;
  int? key;
  MyTask({
    this.startTime,
    this.endTime,
    this.key,
    required this.title,
    this.completed = false,
  });
  final taskManager = getIt<TasksScreenManager>();

  @override
  String toString() {
    return '\n[$key] $title: $completed; $startTime';
  }

  toggleCompleted() {
    completed = !completed;
  }

  updateStartTime(int startTimeHours, int startTimeMinutes) {
    startTime = DateTimeUtils.mixDateAndTime(date: taskManager.selectedDate, hours: startTimeHours, minutes: startTimeMinutes);
    print('updatedStartTime: $startTime');
  }

  updateEndTime(int endTimeHours, int endTimeMinutes) {
    endTime = DateTimeUtils.mixDateAndTime(date: taskManager.selectedDate, hours: endTimeHours, minutes: endTimeMinutes);
    print('updatedStartTime: $endTime');
  }
}
