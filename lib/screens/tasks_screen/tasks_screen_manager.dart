import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:today/globals/constants.dart';
import 'package:today/models/my_task.dart';
import 'package:today/models/my_list.dart';
import 'package:today/services/task_service.dart';
import 'package:today/style/style_constants.dart';
import 'package:today/utils/date_time_utils.dart';

enum NavBarSelection {
  unselected,
  calendar,
  list,
}

class TasksScreenManager {
  final selectedList = ValueNotifier<MyList>(MyList());
  MyTask? _selectedTask;
  MyTask? get selectedTask => _selectedTask;
  set selectTask(MyTask task) => _selectedTask = task;
  unselectTask() {
    _selectedTask = null;
  }

  DateTime _selectedDate = DateTime.now();
  final isSelectedDateToday = ValueNotifier<bool>(true);

  final navBar = ValueNotifier<NavBarSelection>(NavBarSelection.unselected);

  updateNavBarSelection(NavBarSelection newNavBarSelection) => navBar.value = newNavBarSelection;

  DateTime get selectedDate => _selectedDate;

  final pageController = PageController(initialPage: todayIndex, viewportFraction: 0.95);

  updateSelectedDate(DateTime newDateTime) {
    _selectedDate = newDateTime;
    checkIfSelectedDateIsToday();
    listenToDateList();
  }

  updateStartEndTimeToSelectedDate() {
    // when updating date of a task, also update its start/endTime date to selectedDate
    if (_selectedTask!.startTime != null) {
      _selectedTask?.updateStartTime(_selectedTask!.startTime!.hour, _selectedTask!.startTime!.minute);
    }
    if (_selectedTask!.endTime != null) {
      _selectedTask?.updateEndTime(_selectedTask!.endTime!.hour, _selectedTask!.endTime!.minute);
    }
  }

  checkIfSelectedDateIsToday() {
    DateTimeUtils.isSpecialDay(DateTime.now(), _selectedDate) == MyDate.isToday
        ? isSelectedDateToday.value = true
        : isSelectedDateToday.value = false;
  }

  double screenHeight = 0;
  EdgeInsets safeArea = EdgeInsets.zero;
  getScreenMeasurments(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    safeArea = MediaQuery.of(context).padding;
  }

  double calcEmptySpaceHeight() =>
      screenHeight -
      safeArea.top - //iOS status bar
      AppBar().preferredSize.height - //appBar's height
      (selectedList.value.tasks.length * taskCardHeight) -
      completedTitleHeight -
      completedTitleBottomPadding -
      calcFloatingBottomSafeArea();

  double calcFloatingBottomSafeArea() => safeArea.bottom + floatingNavBarContainerHeight + 4;

  changePage(double oldPageIndex, int newPageIndex) {
    // print('$oldPageIndex -> $newPageIndex');
    if (newPageIndex.toDouble() > oldPageIndex) {
      updateSelectedDate(_selectedDate.add(const Duration(days: 1)));
    } else {
      updateSelectedDate(_selectedDate.subtract(const Duration(days: 1)));
    }
  }

  Future removeTaskFromList(MyTask myTask, MyList myList) async {
    // delete myTask from myList locally
    if (!myTask.completed) {
      myList.tasks.remove(myTask);
    } else {
      myList.completedTasks.remove(myTask);
    }

    // delete task in the db
    await TaskService().updateDateListInDatabase(myList);
  }

  Future updateTask({
    required MyTask updatedTask,
    required MyList originalList,
  }) async {
    // check whether the date was changed
    DateTime newDate = _selectedDate;
    if (DateTimeUtils.isSpecialDay(originalList.date!, newDate) == MyDate.isToday) {
      // SAME DAY
      // update the new task to the selectedList locally
      selectedList.value.tasks[updatedTask.key!] = updatedTask;
    } else {
      // DIFF DAY
      // delete the original task from the original date in the db
      await removeTaskFromList(updatedTask, originalList);
      // add new task the selectedList locally
      selectedList.value.tasks.add(updatedTask);
    }

    // update the list with the updated task in db
    log('final updateDateList: ${selectedList.value}');
    await TaskService().updateDateListInDatabase(selectedList.value);
  }

  Future addTaskToDateList(MyTask newTask) async {
    await TaskService().addTaskToDateList(newTask, _selectedDate);
  }

  toggleTaskCompleted(MyTask task) {
    if (!task.completed) {
      selectedList.value.tasks.remove(task);

      task.toggleCompleted();
      selectedList.value.completedTasks.add(task);
      print('Task removed from tasks: ${selectedList.value.tasks}');
      print('Task added to completedTasks: ${selectedList.value.completedTasks}');
    } else {
      selectedList.value.completedTasks.remove(task);

      task.toggleCompleted();
      selectedList.value.tasks.add(task);
      print('Task removed from completedTasks: ${selectedList.value.completedTasks}');
      print('Task added to tasks: ${selectedList.value.tasks}');
    }

    TaskService().updateDateListInDatabase(selectedList.value);
    log('4. \x1B[32mupdateDateListInDatabase: ${selectedList.value.tasks}\x1B[0m');
  }

  reorderList(int oldIndex, int newIndex) {
    // print('0. before ordering List: ${selectedList.value}');

    if (newIndex < oldIndex) {
      newIndex = newIndex + 1;
    }
    final element = selectedList.value.tasks.removeAt(oldIndex);
    selectedList.value.tasks.insert(newIndex, element);
    print('1. reordered List: ${selectedList.value}');
    TaskService().updateDateListInDatabase(selectedList.value);
  }

  StreamSubscription? _subscription;

  listenToDateList() {
    _subscription?.cancel();

    _subscription = TaskService().listenToDateListSnapshot(date: _selectedDate);
    _subscription?.onData((data) {
      try {
        log('selected DAY [$_selectedDate]: ${selectedList.value.tasks}');
        selectedList.value = TaskService().convertFirebaseSnapshotToMyList(
          firebaseSnapshot: data,
          myListTitle: DateTimeUtils.specialDateTimeString(_selectedDate),
          listDate: _selectedDate,
        );
        log('!?! got new data; selectedList.value: ${selectedList.value} ');
      } catch (e) {
        throw 'Error #12: $e';
      }
    });
  }

  disposeSubscription() {
    _subscription?.cancel();
  }
}
