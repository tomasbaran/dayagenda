import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:today/models/my_list.dart';
import 'package:today/models/my_task.dart';
import 'package:today/services/auth_service.dart';
import 'package:logger/logger.dart';

class TaskService {
  final _db = FirebaseFirestore.instance;
  final String? _uid = AuthService().uid;

  Future<DocumentSnapshot<Map<String, dynamic>>> getDateListSnapshot(DateTime date) {
    String listDateId = '${date.year}-${date.month}-${date.day}_$_uid';
    final DocumentReference<Map<String, dynamic>> listDocRef = _db.collection("users").doc(_uid).collection('date_lists').doc(listDateId);
    return listDocRef.get();
  }

  // REFACTOR #100: ? maybe better have two seperate functions: getListByDate, getListById
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? listenToDateListSnapshot({DateTime? date, String? listId}) {
    if (_uid == null) {
      throw ('Error #2[getting list]: User not signed in.');
    } else {
      final DocumentReference<Map<String, dynamic>> listDocRef;
      // REFACTOR #100: ? maybe better have two seperate functions: getListByDate, getListById
      if (date != null) {
        String listDateId = '${date.year}-${date.month}-${date.day}_$_uid';
        listDocRef = _db.collection("users").doc(_uid).collection('date_lists').doc(listDateId);
      } else {
        listDocRef = _db.collection("users").doc(_uid).collection('id_lists').doc(listId);
      }

      return listDocRef.snapshots().listen(
        (event) {
          log('event: $event;${event.data()}');
        },
        onError: (error) {
          log('Error #4: Listen failed: $error');
          throw 'Error #4: Listen failed: $error';
        },
      );
    }
  }

  updateDateListInDatabase(MyList updatedList) {
    if (_uid == null) {
      throw ('Error #6[updating task]: User not signed in.');
    } else {
      Map<String, dynamic> formattedUpdatedList = formatMyListToFirebaseList(updatedList);
      final listDocRef = _db.collection('users').doc(_uid).collection('date_lists').doc(updatedList.id);

      listDocRef.set(formattedUpdatedList).onError((error, stackTrace) {
        log('\x1B[31mError #6[updating task]: $error\x1B[0m');
        Logger(printer: PrettyPrinter(colors: false)).e('Error #6[updating task]: $error');
      });
    }
  }

  addTaskToDateList(MyTask myTask, DateTime date) {
    if (_uid == null) {
      throw ('Error #1[adding task]: User not signed in.');
    } else {
      String listDateId = '${date.year}-${date.month}-${date.day}_$_uid';
      final listDocRef = _db.collection("users").doc(_uid).collection('date_lists').doc(listDateId);

      final formattedTask = formatMyTaskToFirebaseTask(myTask);
      print('adding new task: $formattedTask');

      listDocRef.set({
        'tasks': FieldValue.arrayUnion([formattedTask])
      }, SetOptions(merge: true)).then((value) {
        print('added a new task: $formattedTask');
      }, onError: (e) {
        log('\x1B[31mError #3[adding task]: $e\x1B[0m');
        Logger(printer: PrettyPrinter(colors: false)).e('Error #3[adding task]: $e');
      });
    }
  }

  Map<String, dynamic> formatMyTaskToFirebaseTask(MyTask myTask) => {
        'title': myTask.title,
        'completed': myTask.completed,
        'start_time': myTask.startTime == null ? null : convertDateTimeToTimestamp(myTask.startTime!),
        'end_time': myTask.endTime == null ? null : convertDateTimeToTimestamp(myTask.endTime!),
      };

  Map<String, dynamic> formatMyListToFirebaseList(MyList myList) {
    List<Map> firebaseTasks = [];
    for (var myTask in myList.tasks) {
      Map firebaseTask = formatMyTaskToFirebaseTask(myTask);
      firebaseTasks.add(firebaseTask);
    }

    List<Map> firebaseCompletedTasks = [];
    for (var myTask in myList.completedTasks) {
      Map firebaseTask = formatMyTaskToFirebaseTask(myTask);
      firebaseCompletedTasks.add(firebaseTask);
    }

    Map<String, dynamic> firebaseList = {
      'tasks': firebaseTasks,
      'completed_tasks': firebaseCompletedTasks,
    };
    log('2. formattedList: $firebaseList');

    return firebaseList;
  }

  DateTime convertTimestampToDateTime(Timestamp timestamp) => DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
  Timestamp convertDateTimeToTimestamp(DateTime dateTime) => Timestamp.fromMillisecondsSinceEpoch(dateTime.millisecondsSinceEpoch);

  List<MyTask> convertFirebaseTasksToMyListItems(List? firebaseTasks) {
    List<MyTask> output = [];
    if (firebaseTasks != null) {
      firebaseTasks.asMap().forEach(
        (key, value) {
          MyTask myTask = MyTask(
            key: key,
            title: value['title'],
            completed: value['completed'],
            startTime: value['start_time'] == null ? null : convertTimestampToDateTime(value['start_time']),
            endTime: value['end_time'] == null ? null : convertTimestampToDateTime(value['end_time']),
          );
          output.add(myTask);
        },
      );
    }

    return output;
  }

  MyList convertFirebaseSnapshotToMyList({
    required DocumentSnapshot<Map<String, dynamic>> firebaseSnapshot,
    required String myListTitle,
    DateTime? listDate,
  }) {
    MyList myList = MyList();
    myList.title = myListTitle;
    myList.date = listDate;
    myList.id = firebaseSnapshot.id;

    final Map<String, dynamic>? firebaseList = firebaseSnapshot.data();

    if (firebaseList == null) {
      // there are no tasks for that day assigned (yet)
      print('no tasks for day: ${myList.title}');
      return myList;
    } else {
      myList.tasks = convertFirebaseTasksToMyListItems(firebaseList['tasks']);
      myList.completedTasks = convertFirebaseTasksToMyListItems(firebaseList['completed_tasks']);
      return myList;
    }
  }
}
