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

  StreamSubscription? listSubscription;

  listenToDateList() {
    listSubscription?.cancel();

    listSubscription = listService.listenToDateListSnapshot(date: dateState.selectedDate.value);
    listSubscription?.onData((data) {
      try {
        log(name: 'got data', '${dateState.selectedDate.value}');
        value = listService.convertFirebaseSnapshotToMyList(
          firebaseSnapshot: data,
          myListTitle: DateTimeUtils.specialDateTimeString(dateState.selectedDate.value),
          listDate: dateState.selectedDate.value,
        );
        debugPrint('\x1B[3m\x1B[33m[!updated list] ${value.date}: $value\x1B[0m---');
        debugPrint('\x1B[3m\x1B[33m[-------------updated list finish----------------] \x1B[0m\n\n');
      } catch (e) {
        throw 'Error #12: $e';
      }
    });
  }

  disposeSubscription() {
    listSubscription?.cancel();
  }

  reorderList(int oldIndex, int newIndex) async {
    // print('0. before ordering List: ${selectedList.value}');

    if (newIndex < oldIndex) {
      newIndex = newIndex + 1;
    }
    final element = value.tasks.removeAt(oldIndex);
    value.tasks.insert(newIndex, element);
    log('\x1B[32m1. reordered List: $value \x1B[0m');
    await listService.updateDateListInCloud(value);
  }

  Future updateListByTaskIsCompleted(MyTask updatedTask) async {
    // MyList tmpMyList = listState.selectedList.value.clone();
    if (updatedTask.isCompleted) {
      // ALT: tmpMyList.tasks.removeAt(task.key!);
      try {
        value.tasks.removeWhere((element) => element.key == updatedTask.key);
        value.completedTasks.add(updatedTask);
      } catch (e) {
        log('\x1B[31mError #13[updateListByTaskIsCompleted]: $e\x1B[0m');
      }
    } else {
      // ALT: tmpMyList.completedTasks.removeAt(task.key!);
      value.completedTasks.removeWhere((element) => element.key == updatedTask.key);
      value.tasks.add(updatedTask);
    }

    log('\x1B[35m${updatedTask.title}: ${updatedTask.isCompleted}\x1B[0m', name: 'mark as completed');
    debugPrint('$value[---------updateDateListInCloud finish------]');

    await listService.updateDateListInCloud(value);
  }

  Future updateSameDateListByTask(MyTask updatedTask) async {
    // update the new task to the selectedList locally
    value.tasks[updatedTask.key!] = updatedTask;
    // update the updated list in the db
    await listService.updateDateListInCloud(value);
  }
}
