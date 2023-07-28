import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:today/models/my_list.dart';
import 'package:today/models/my_task.dart';

abstract class ListService {
  Future<DocumentSnapshot<Map<String, dynamic>>> getDateListSnapshot(DateTime date);

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? listenToDateListSnapshot({DateTime? date, String? listId});

  Future removeTaskFromList(MyTask myTask, MyList myList);

  Future updateDateListInDatabase(MyList updatedList);

  Future addTaskToDateList(MyTask myTask, DateTime date);

  Map<String, dynamic> formatMyTaskToFirebaseTask(MyTask myTask);

  Map<String, dynamic> formatMyListToFirebaseList(MyList myList);

  List<MyTask> convertFirebaseTasksToMyListItems(List? firebaseTasks);

  MyList convertFirebaseSnapshotToMyList({
    required DocumentSnapshot<Map<String, dynamic>> firebaseSnapshot,
    required String myListTitle,
    DateTime? listDate,
  });
}
