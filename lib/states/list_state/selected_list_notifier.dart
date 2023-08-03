import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:today/models/my_list.dart';
import 'package:today/models/my_task.dart';
import 'package:today/services/list_service/list_service.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/states/date_state.dart';
import 'package:today/utils/date_time_utils.dart';

class SelectedListNotifier extends ValueNotifier<MyList> {
  SelectedListNotifier() : super(MyList());

  final listService = getIt<ListService>();
  final dateState = getIt<DateState>();

  StreamSubscription? _subscription;

  listenToDateList() {
    _subscription?.cancel();

    _subscription = listService.listenToDateListSnapshot(date: dateState.selectedDate);
    _subscription?.onData((data) {
      try {
        value = listService.convertFirebaseSnapshotToMyList(
          firebaseSnapshot: data,
          myListTitle: DateTimeUtils.specialDateTimeString(dateState.selectedDate),
          listDate: dateState.selectedDate,
        );
        log('\x1B[3m\x1B[33m!got new data; selectedList.value: $value\x1B[0m');
      } catch (e) {
        throw 'Error #12: $e';
      }
    });
  }

  disposeSubscription() {
    _subscription?.cancel();
  }

  reorderList(int oldIndex, int newIndex) {
    // print('0. before ordering List: ${selectedList.value}');

    if (newIndex < oldIndex) {
      newIndex = newIndex + 1;
    }
    final element = value.tasks.removeAt(oldIndex);
    value.tasks.insert(newIndex, element);
    log('\x1B[32m1. reordered List: $value \x1B[0m');
    listService.updateDateListInCloud(value);
  }

  updateListByTaskIsCompleted(MyTask updatedTask) {
    // MyList tmpMyList = listState.selectedList.value.clone();
    if (updatedTask.isCompleted) {
      // ALT: tmpMyList.tasks.removeAt(task.key!);
      value.tasks.removeWhere((element) => element.key == updatedTask.key);
      value.completedTasks.add(updatedTask);
    } else {
      // ALT: tmpMyList.completedTasks.removeAt(task.key!);
      value.completedTasks.removeWhere((element) => element.key == updatedTask.key);
      value.tasks.add(updatedTask);
    }

    listService.updateDateListInCloud(value);
  }

  updateSameDateListByTask(MyTask updatedTask) {
    // update the new task to the selectedList locally
    value.tasks[updatedTask.key!] = updatedTask;
    // update the updated list in the db
    listService.updateDateListInCloud(value);
  }
}
