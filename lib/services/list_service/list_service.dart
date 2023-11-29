import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayagenda/models/my_list.dart';
import 'package:dayagenda/models/my_task.dart';

abstract class ListService {
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? streamDateList({DateTime? date, String? listId});

  Future removeTaskFromListInCloud(MyTask myTask, MyList myList);

  Future updateDateListInCloud(MyList updatedList);

  Future addTaskToDateListInCloud(MyTask myTask, DateTime date);

  Map<String, dynamic> formatMyTaskToFirebaseTask(MyTask myTask);

  Map<String, dynamic> formatMyListToFirebaseList(MyList myList);

  List<MyTask> convertFirebaseTasksToMyListItems(List? firebaseTasks);

  MyList convertFirebaseSnapshotToMyList({
    required DocumentSnapshot<Map<String, dynamic>> firebaseSnapshot,
    required String myListTitle,
    DateTime? listDate,
  });
}
