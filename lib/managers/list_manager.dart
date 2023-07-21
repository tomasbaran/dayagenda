import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:today/managers/date_manager.dart';
import 'package:today/models/enums.dart';
import 'package:today/models/my_task.dart';
import 'package:today/models/my_list.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/services/task_service.dart';
import 'package:today/utils/date_time_utils.dart';

class ListManager {
  final selectedList = ValueNotifier<MyList>(MyList());

  final dateManager = getIt<DateManager>();

  selectDateListByPage(double oldPageIndex, int newPageIndex) {
    // print('$oldPageIndex -> $newPageIndex');
    dateManager.selecteNewDate(dateManager.selectedDate.add(Duration(days: newPageIndex.toDouble() > oldPageIndex ? 1 : -1)));
    listenToDateList();
  }

  selectListByDate(DateTime newDate) {
    dateManager.selecteNewDate(newDate);
    listenToDateList();
  }

  Future addTaskToDateList(MyTask newTask) async {
    await TaskService().addTaskToDateList(newTask, dateManager.selectedDate);
  }

  Future removeTaskFromList(MyTask myTask, MyList myList) async {
    // delete myTask from myList locally
    if (!myTask.isCompleted) {
      myList.tasks.remove(myTask);
    } else {
      myList.completedTasks.remove(myTask);
    }

    // delete task in the db
    await TaskService().updateDateListInDatabase(myList);
  }

  updateListByTaskIsCompleted(MyTask updatedTask) {
    // MyList tmpMyList = listManager.selectedList.value.clone();
    if (updatedTask.isCompleted) {
      // ALT: tmpMyList.tasks.removeAt(task.key!);
      selectedList.value.tasks.removeWhere((element) => element.key == updatedTask.key);
      selectedList.value.completedTasks.add(updatedTask);
    } else {
      // ALT: tmpMyList.completedTasks.removeAt(task.key!);
      selectedList.value.completedTasks.removeWhere((element) => element.key == updatedTask.key);
      selectedList.value.tasks.add(updatedTask);
    }

    TaskService().updateDateListInDatabase(selectedList.value);
  }

  updateSameDateListByTask(MyTask updatedTask) {
    // update the new task to the selectedList locally
    selectedList.value.tasks[updatedTask.key!] = updatedTask;
    // update the updated list in the db
    TaskService().updateDateListInDatabase(selectedList.value);
  }

  Future updateListByTask({
    required MyTask updatedTask,
    required MyList originalList,
  }) async {
    // check whether the date of the updatedTask was changed
    if (DateTimeUtils.isSpecialDay(originalList.date!, dateManager.selectedDate) == MyDate.isToday) {
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
    TaskService().updateDateListInDatabase(selectedList.value);
  }

  StreamSubscription? _subscription;

  listenToDateList() {
    _subscription?.cancel();

    _subscription = TaskService().listenToDateListSnapshot(date: dateManager.selectedDate);
    _subscription?.onData((data) {
      try {
        selectedList.value = TaskService().convertFirebaseSnapshotToMyList(
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
