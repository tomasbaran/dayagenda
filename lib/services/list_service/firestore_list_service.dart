import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:today/models/my_list.dart';
import 'package:today/models/my_task.dart';
import 'package:today/services/auth_service.dart';
import 'package:logger/logger.dart';
import 'package:today/services/list_service/list_service.dart';
import 'package:today/utils/date_time_utils.dart';

class FirestoreListService extends ListService {
  final _db = FirebaseFirestore.instance;
  final String? _uid = AuthService().uid;

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getDateListSnapshot(DateTime date) {
    String listDateId = '${date.year}-${date.month}-${date.day}_$_uid';
    final DocumentReference<Map<String, dynamic>> listDocRef = _db.collection("users").doc(_uid).collection('date_lists').doc(listDateId);
    return listDocRef.get();
  }

  // REFACTOR #100: ? maybe better have two seperate functions: getListByDate, getListById
  @override
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
          log('\x1B[31mError #4: Listen failed: $error \x1B[0m');
          throw '\x1B[31mError #4: Listen failed: $error \x1B[0m';
        },
      );
    }
  }

  @override
  Future removeTaskFromList(MyTask myTask, MyList myList) async {
    MyList tmpList = myList.clone();
    // delete myTask from myList locally
    if (!myTask.isCompleted) {
      tmpList.tasks.removeAt(myTask.key!);
    } else {
      tmpList.completedTasks.removeAt(myTask.key!);
    }
    // delete task in the db
    await updateDateListInDatabase(tmpList);
  }

  @override
  Future updateDateListInDatabase(MyList updatedList) async {
    if (_uid == null) {
      throw ('\x1B[31mError #6[updating task]: User not signed in.\x1B[0m');
    } else {
      final listDocRef = _db.collection('users').doc(_uid).collection('date_lists').doc(updatedList.id);
      Map<String, dynamic> formattedUpdatedList = formatMyListToFirebaseList(updatedList);

      await listDocRef.set(formattedUpdatedList).onError((error, stackTrace) {
        log('\x1B[31mError #6[updating task]: $error\x1B[0m');
        Logger(printer: PrettyPrinter(colors: false)).e('Error #6[updating task]: $error');
      });
      log(' \x1B[33m3. updatedList\x1B[0m');
    }
  }

  @override
  Future addTaskToDateList(MyTask myTask, DateTime date) async {
    if (_uid == null) {
      throw ('Error #1[adding task]: User not signed in.');
    } else {
      String listDateId = '${date.year}-${date.month}-${date.day}_$_uid';
      final listDocRef = _db.collection("users").doc(_uid).collection('date_lists').doc(listDateId);

      final formattedTask = formatMyTaskToFirebaseTask(myTask);

      await listDocRef.set({
        'tasks': FieldValue.arrayUnion([formattedTask])
      }, SetOptions(merge: true)).then((value) {
        log('\x1B[33madded a new task: $formattedTask\x1B[0m');
      }, onError: (e) {
        log('\x1B[31mError #3[adding task]: $e\x1B[0m');
        Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding task]: $e\x1B[0m');
      });
    }
  }

  @override
  Map<String, dynamic> formatMyTaskToFirebaseTask(MyTask myTask) => {
        'title': myTask.title,
        'completed': myTask.isCompleted,
        'start_time': DateTimeUtils.convertDateTimeToTimestamp(myTask.startTime),
        'end_time': DateTimeUtils.convertDateTimeToTimestamp(myTask.endTime),
      };

  @override
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
    log('\x1B[37m2. formattedList: $firebaseList  \x1B[0m');

    return firebaseList;
  }

  @override
  List<MyTask> convertFirebaseTasksToMyListItems(List? firebaseTasks) {
    List<MyTask> output = [];
    if (firebaseTasks != null) {
      firebaseTasks.asMap().forEach(
        (key, value) {
          MyTask myTask = MyTask(
            key: key,
            title: value['title'],
            isCompleted: value['completed'],
            startTime: DateTimeUtils.convertTimestampToDateTime(value['start_time']),
            endTime: DateTimeUtils.convertTimestampToDateTime(value['end_time']),
          );
          output.add(myTask);
        },
      );
    }

    return output;
  }

  @override
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
      return myList;
    } else {
      myList.tasks = convertFirebaseTasksToMyListItems(firebaseList['tasks']);
      myList.completedTasks = convertFirebaseTasksToMyListItems(firebaseList['completed_tasks']);
      return myList;
    }
  }
}
