import 'dart:async';

import 'package:today/services/mixpanel_service.dart';
import 'package:today/states/date_state.dart';
import 'package:today/models/enums.dart';
import 'package:today/models/my_task.dart';
import 'package:today/models/my_list.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/services/list_service/list_service.dart';
import 'package:today/utils/date_time_utils.dart';
import 'selected_list_notifier.dart';

class ListState {
  final selectedList = SelectedListNotifier();
  listenToDateList() => selectedList.listenToDateList();
  disposeSubscription() => selectedList.disposeSubscription();
  reorderList(int oldIndex, int newIndex) => selectedList.reorderList(oldIndex, newIndex);
  updateListByTaskIsCompleted(MyTask updatedTask) => selectedList.updateListByTaskIsCompleted(updatedTask);
  updateSameDateListByTask(MyTask updatedTask) => selectedList.updateSameDateListByTask(updatedTask);

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

  Future addTaskToDateList(MyTask newTask, {bool trackInMixpanel = true}) async {
    if (trackInMixpanel) {
      MixpanelService.mixpanel?.track('Add Task', properties: {'task title': newTask.title});
    }
    await listService.addTaskToDateListInCloud(newTask, dateState.selectedDate.value);
  }

  Future removeTaskFromList(MyTask myTask, MyList myList) async => listService.removeTaskFromListInCloud(myTask, myList);

  Future updateListByTask({
    required MyTask updatedTask,
    required MyList originalList,
  }) async {
    // check whether the date of the updatedTask was changed
    if (DateTimeUtils.isSpecialDay(originalList.date!, dateState.selectedDate.value) == DayType.isToday) {
      // SAME DAY
      updateSameDateListByTask(updatedTask);
    } else {
      // DIFF DAY
      // delete the original task from the original date in the db
      removeTaskFromList(updatedTask, originalList);
      // add task to list in the db
      addTaskToDateList(updatedTask);
    }
  }
}
