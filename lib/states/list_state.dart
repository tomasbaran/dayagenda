import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:today/states/date_manager.dart';
import 'package:today/models/enums.dart';
import 'package:today/models/my_task.dart';
import 'package:today/models/my_list.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/services/list_service/list_service.dart';
import 'package:today/utils/date_time_utils.dart';

class ListState {
  final selectedList = ValueNotifier<MyList>(MyList());

  final dateManager = getIt<DateManager>();
  final listService = getIt<ListService>();

  selectDateListByPage(double oldPageIndex, int newPageIndex) {
    dateManager.selecteNewDate(dateManager.selectedDate.add(Duration(days: newPageIndex.toDouble() > oldPageIndex ? 1 : -1)));
    listenToDateList();
  }

  selectDateListByDate(DateTime newDate) {
    dateManager.selecteNewDate(newDate);
    listenToDateList();
  }

  Future addTaskToDateList(MyTask newTask) async => await listService.addTaskToDateList(newTask, dateManager.selectedDate);

  Future removeTaskFromList(MyTask myTask, MyList myList) async {
    MyList tmpList = myList.clone();
    // delete myTask from myList locally
    if (!myTask.isCompleted) {
      tmpList.tasks.removeAt(myTask.key!);
    } else {
      tmpList.completedTasks.removeAt(myTask.key!);
    }
    // delete task in the db
    await listService.updateDateListInDatabase(tmpList);
    log('selectedList: $selectedList');
  }

  updateListByTaskIsCompleted(MyTask updatedTask) {
    // MyList tmpMyList = listState.selectedList.value.clone();
    if (updatedTask.isCompleted) {
      // ALT: tmpMyList.tasks.removeAt(task.key!);
      selectedList.value.tasks.removeWhere((element) => element.key == updatedTask.key);
      selectedList.value.completedTasks.add(updatedTask);
    } else {
      // ALT: tmpMyList.completedTasks.removeAt(task.key!);
      selectedList.value.completedTasks.removeWhere((element) => element.key == updatedTask.key);
      selectedList.value.tasks.add(updatedTask);
    }

    listService.updateDateListInDatabase(selectedList.value);
  }

  updateSameDateListByTask(MyTask updatedTask) {
    // update the new task to the selectedList locally
    selectedList.value.tasks[updatedTask.key!] = updatedTask;
    // update the updated list in the db
    listService.updateDateListInDatabase(selectedList.value);
  }

  Future updateListByTask({
    required MyTask updatedTask,
    required MyList originalList,
  }) async {
    // check whether the date of the updatedTask was changed
    if (DateTimeUtils.isSpecialDay(originalList.date!, dateManager.selectedDate) == DayType.isToday) {
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

  reorderList(int oldIndex, int newIndex) {
    // print('0. before ordering List: ${selectedList.value}');

    if (newIndex < oldIndex) {
      newIndex = newIndex + 1;
    }
    final element = selectedList.value.tasks.removeAt(oldIndex);
    selectedList.value.tasks.insert(newIndex, element);
    log('\x1B[32m1. reordered List: ${selectedList.value} \x1B[0m');
    listService.updateDateListInDatabase(selectedList.value);
  }

  StreamSubscription? _subscription;

  listenToDateList() {
    _subscription?.cancel();

    _subscription = listService.listenToDateListSnapshot(date: dateManager.selectedDate);
    _subscription?.onData((data) {
      try {
        selectedList.value = listService.convertFirebaseSnapshotToMyList(
          firebaseSnapshot: data,
          myListTitle: DateTimeUtils.specialDateTimeString(dateManager.selectedDate),
          listDate: dateManager.selectedDate,
        );
        log('\x1B[3m\x1B[33m!got new data; selectedList.value: ${selectedList.value}\x1B[0m');
      } catch (e) {
        throw 'Error #12: $e';
      }
    });
  }

  disposeSubscription() {
    _subscription?.cancel();
  }
}
