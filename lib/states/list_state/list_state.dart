import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayagenda/services/analytics_service.dart';
import 'package:dayagenda/services/firebase_analytics_service.dart';
import 'package:dayagenda/services/mixpanel_service.dart';
import 'package:dayagenda/states/date_state.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/models/my_task.dart';
import 'package:dayagenda/models/my_list.dart';
import 'package:dayagenda/services/service_locator.dart';
import 'package:dayagenda/services/list_service/list_service.dart';
import 'package:dayagenda/states/task_state.dart';
import 'package:dayagenda/utils/date_time_utils.dart';
import 'selected_list_notifier.dart';

class ListState {
  final selectedList = SelectedListNotifier();

  final List<MyList> idLists = [];

  selectDateList() => selectedList.selectDateList();
  selectIdList(String id) => selectedList.selectIdList(id);

  disposeSelectedListSubscription() => selectedList.disposeSelectedListSubscription();
  Future reorderList(int oldIndex, int newIndex) async => selectedList.reorderList(oldIndex, newIndex);
  Future updateListByTaskIsCompleted(MyTask updatedTask) async => selectedList.updateListByTaskIsCompleted(updatedTask);
  Future updateSameDateListByTask(MyTask updatedTask) async => selectedList.updateSameDateListByTask(updatedTask);

  final dateState = getIt<DateState>();
  final listService = getIt<ListService>();

  StreamSubscription? idListsSubscription;

  disposeStreamUserIdLists() => idListsSubscription?.cancel();

  streamUserIdLists() {
    idListsSubscription?.cancel();

    idListsSubscription = listService.streamUserIdLists();
    idListsSubscription?.onData((data) {
      try {
        MyList foundList;
        for (var doc in data.docs) {
          final idList = doc.data();
          // log(name: 'doc', '$idList');
          foundList = MyList(
            title: idList['title'],
            id: doc.id,
          );
          idLists.add(foundList);
          // log(name: 'idLists', '$idLists');
        }

        // value = listService.convertFirebaseSnapshotToMyList(
        //   firebaseSnapshot: data,
        //   myListTitle: DateTimeUtils.specialDateTimeString(dateState.selectedDate.value),
        //   listDate: dateState.selectedDate.value,
        // );
      } catch (e) {
        throw 'Error #12: $e';
      }
    });
  }

  Future<DocumentReference> createNewIdList({required String title}) async => await listService.createIdList(title);

  selectDateListByPage(double oldPageIndex, int newPageIndex) {
    dateState.selecteNewDate(dateState.selectedDate.value.add(Duration(days: newPageIndex.toDouble() > oldPageIndex ? 1 : -1)));
    selectDateList();
  }

  selectDateListByDate(DateTime newDate) {
    dateState.selecteNewDate(newDate);
    selectDateList();
  }

  Future addTaskToList(MyTask newTask, {bool trackInMixpanel = true, DateTime? dateList}) async {
    await AnalyticsService().updateUserStatOnAddedTodo(newTask, dateState.selectedDate.value);
    if (trackInMixpanel) {
      FirebaseAnalyticsService.analytics.logEvent(name: 'add_todo', parameters: {'type': newTask.startTime == null ? 'task' : 'event'});
      MixpanelService.mixpanel?.track('Add Todo', properties: {'type': newTask.startTime == null ? 'task' : 'event'});
    }
    if (dateList != null) {
      await listService.addTaskToDateListInCloud(newTask, dateList);
    }
    if (newTask.idList != null) {
      //TODO:
    }
  }

  Future removeTaskFromList(MyTask myTask, MyList myList) async {
    await AnalyticsService().updateUserStatOnDeletedTodo(myTask, myList.date);

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
      addTaskToList(updatedTask, dateList: dateState.selectedDate.value);
    }
  }

  Future snoozeTodoToTomorrow(MyTask myTask) async {
    AnalyticsService().trackSnooze(myTask);
    final taskState = getIt<TaskState>();
    taskState.updateMyTaskStateWhenBeingSnoozed(myTask, true);

    MyTask updatedTask = myTask.clone();
    if (updatedTask.startTime != null) {
      updatedTask.startTime = updatedTask.startTime!.add(const Duration(days: 1));
    }
    if (updatedTask.endTime != null) {
      updatedTask.endTime = updatedTask.endTime!.add(const Duration(days: 1));
    }
    // delete the original task from the original date in the db
    await removeTaskFromList(myTask, selectedList.value);
    // add task to list in the db
    await addTaskToList(updatedTask, dateList: dateState.selectedDate.value.add(const Duration(days: 1)), trackInMixpanel: false);
    taskState.updateMyTaskStateWhenBeingSnoozed(myTask, false);
  }
}
