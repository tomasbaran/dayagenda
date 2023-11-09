import 'dart:async';

import 'package:dayagenda/services/analytics_service.dart';
import 'package:dayagenda/services/mixpanel_service.dart';
import 'package:dayagenda/states/date_state.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/models/my_task.dart';
import 'package:dayagenda/models/my_list.dart';
import 'package:dayagenda/services/service_locator.dart';
import 'package:dayagenda/services/list_service/list_service.dart';
import 'package:dayagenda/utils/date_time_utils.dart';
import 'selected_list_notifier.dart';

class ListState {
  final selectedList = SelectedListNotifier();
  listenToDateList() => selectedList.listenToDateList();
  disposeSubscription() => selectedList.disposeSubscription();
  Future reorderList(int oldIndex, int newIndex) async => selectedList.reorderList(oldIndex, newIndex);
  Future updateListByTaskIsCompleted(MyTask updatedTask) async => selectedList.updateListByTaskIsCompleted(updatedTask);
  Future updateSameDateListByTask(MyTask updatedTask) async => selectedList.updateSameDateListByTask(updatedTask);

  final dateState = getIt<DateState>();
  final listService = getIt<ListService>();

  selectDateListByPage(double oldPageIndex, int newPageIndex) {
    dateState.selecteNewDate(dateState.selectedDate.value.add(Duration(days: newPageIndex.toDouble() > oldPageIndex ? 1 : -1)));
    listenToDateList();
  }

  selectDateListByDate(DateTime newDate) {
    dateState.selecteNewDate(newDate);
    listenToDateList();
  }

  Future addTaskToDateList(MyTask newTask, {bool trackInMixpanel = true, DateTime? dateList}) async {
    await AnalyticsService().updateUserStatOnAddedTodo(newTask, dateState.selectedDate.value);
    if (trackInMixpanel) {
      MixpanelService.mixpanel?.track('Add Todo', properties: {'todo title': newTask.title});
    }

    await listService.addTaskToDateListInCloud(newTask, dateList ?? dateState.selectedDate.value);
  }

  Future removeTaskFromList(MyTask myTask, MyList myList) async {
    await AnalyticsService().updateUserStatOnDeletedTodo(myTask, dateState.selectedDate.value);

    listService.removeTaskFromListInCloud(myTask, myList);
  }

  Future updateListByTask({
    required MyTask updatedTask,
    required MyList originalList,
  }) async {
    // check whether the date of the updatedTask was changed
    if (DateTimeUtils.isSpecialDay(originalList.date!, dateState.selectedDate.value) == DayType.isToday) {
      // SAME DAY
      await updateSameDateListByTask(updatedTask);
    } else {
      // DIFF DAY
      // delete the original task from the original date in the db
      removeTaskFromList(updatedTask, originalList);
      // add task to list in the db
      addTaskToDateList(updatedTask);
    }
  }

  Future snoozeTodoToTomorrow(MyTask myTask) async {
    MyTask updatedTask = myTask.clone();
    if (updatedTask.startTime != null) {
      updatedTask.startTime = updatedTask.startTime!.add(const Duration(days: 1));
    }
    if (updatedTask.endTime != null) {
      updatedTask.endTime = updatedTask.startTime!.add(const Duration(days: 1));
    }
    // delete the original task from the original date in the db
    await removeTaskFromList(updatedTask, selectedList.value);
    // add task to list in the db
    await addTaskToDateList(updatedTask, dateList: dateState.selectedDate.value.add(const Duration(days: 1)));
  }
}
