import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayagenda/models/my_list.dart';
import 'package:dayagenda/models/my_task.dart';

abstract class ListService {
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? streamUserIdLists();

  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? streamDateList({required DateTime date});
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? streamIdList({required String id});

  Future removeTaskFromListInCloud(MyTask myTask, MyList myList);

  Future updateDateListInCloud(MyList updatedList);

  Future createIdList(String title);

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
