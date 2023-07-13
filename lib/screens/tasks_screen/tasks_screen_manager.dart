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

  removeSelectedTaskByDate({
    required DateTime date,
  }) async {
    // delete task locally and save it tmp as updatedLocalDateList
    MyList updatedLocalDateList = await removeSelectedTaskLocallyByDate(date);
    // delete task in the db
    await TaskService().updateDateListInDatabase(updatedLocalDateList);
  }

  removeSelectedTaskLocallyByDate(DateTime date) async {
    final dateListSnapshot = await TaskService().getDateListSnapshot(date);
    MyList tmpDateList = TaskService().convertFirebaseSnapshotToMyList(
      firebaseSnapshot: dateListSnapshot,
      myListTitle: DateTimeUtils.niceDateTimeString(date),
      listDate: date,
    );
    log('old dateList: ${tmpDateList.tasks}');
    // delete from tasks list (uncompleted)
    if (_selectedTask?.completed == null || !_selectedTask!.completed) {
      tmpDateList.tasks.removeAt(selectedTask!.key!);
      // delete from completedTasks list (completed)
    } else {
      tmpDateList.completedTasks.removeAt(selectedTask!.key!);
    }

    log('new dateList: ${tmpDateList.tasks}');
    return tmpDateList;
  }

  updateTask({
    required DateTime originalDate,
    String? newTitle,
    DateTime? newStartTime,
    DateTime? newEndTime,
  }) async {
    MyTask? originalTask = _selectedTask;

    log('\x1B[31moriginal[$originalDate]selectedTask[${originalTask!.key}]: ${originalTask.title}');

    DateTime newDate = _selectedDate;

    MyTask newTask = originalTask;
    if (newTitle != null) {
      newTask.title = newTitle;
    }
    if (newStartTime != null) {
      newTask.startTime = DateTime(newDate.year, newDate.month, newDate.day, newStartTime.hour, newStartTime.minute);
    }
    if (newEndTime != null) {
      newTask.endTime = DateTime(newDate.year, newDate.month, newDate.day, newEndTime.hour, newEndTime.minute);
    }
    log('\x1B[32m[$newDate]widgetManager.updateTask: ${newTask.title}, ${newTask.startTime}, ${newTask.endTime}  \x1B[0m');

    // check whether the date was changed
    if (DateTimeUtils.isSpecialDay(originalDate, newDate) == MyDate.isToday) {
      // SAME DAY
      log('original: SAME DAY[${newTask.key}]: ${selectedList.value.tasks[newTask.key!]}');
      // update the new task to the selectedList locally
      selectedList.value.tasks[newTask.key!] = newTask;
      log('new: SAME DAY[${newTask.key}]: ${selectedList.value.tasks[newTask.key!]}');
    } else {
      // DIFF DAY
      log('DIFF DAY');
      // delete the original task from the original date in the db
      print('selectedDate: $selectedDate; originalDate: $originalDate');
      print('selectedTask: $selectedTask; originalTask: $originalTask');
      removeSelectedTaskByDate(date: originalDate);
      // add new task the selectedList locally
      selectedList.value.tasks.add(newTask);
    }

    // update the list with the updated task in db
    log('final updateDateList: ${selectedList.value}');
    TaskService().updateDateListInDatabase(selectedList.value);
  }

  addTaskToDateList(MyTask newTask) {
    TaskService().addTaskToDateList(newTask, _selectedDate);
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
          myListTitle: DateTimeUtils.niceDateTimeString(_selectedDate),
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
