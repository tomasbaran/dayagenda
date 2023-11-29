import 'dart:async';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayagenda/models/my_list.dart';
import 'package:dayagenda/models/my_task.dart';
import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:logger/logger.dart';
import 'package:dayagenda/services/list_service/list_service.dart';
import 'package:dayagenda/services/service_locator.dart';
import 'package:dayagenda/utils/date_time_utils.dart';
import 'package:intl/intl.dart';

class FirestoreListService extends ListService {
  final db = FirebaseFirestore.instance;
  String? get uid => getIt<AuthService>().uid;

  @override
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? streamUserIdLists() {
    if (uid == null) {
      throw ('Error #2[getting list]: User not signed in.');
    } else {
      return db.collection("user_lists").doc(uid).collection('id_lists').snapshots().listen(
        (event) {
          log('event: $event;${event.docs}');
        },
        onError: (error) {
          log('\x1B[31mError #4: Listen failed: $error \x1B[0m');
          throw '\x1B[31mError #4: Listen failed: $error \x1B[0m';
        },
      );
    }
  }

  @override
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? streamDateList({required DateTime date}) {
    if (uid == null) {
      throw ('Error #2[getting list]: User not signed in.');
    } else {
      final DocumentReference<Map<String, dynamic>> listDocRef;
      String listDate = DateFormat('yyyy-MM-dd').format(date);
      listDocRef = db.collection("user_lists").doc(uid).collection('date_lists').doc(listDate);

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
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? streamIdList({required String id}) {
    if (uid == null) {
      throw ('Error #2[getting list]: User not signed in.');
    } else {
      final DocumentReference<Map<String, dynamic>> listDocRef;
      listDocRef = db.collection("user_lists").doc(uid).collection('id_lists').doc(id);

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
  Future removeTaskFromListInCloud(MyTask myTask, MyList myList) async {
    MyList tmpList = myList.clone();
    // delete myTask from myList locally
    if (!myTask.isCompleted) {
      tmpList.tasks.removeAt(myTask.key!);
    } else {
      tmpList.completedTasks.removeAt(myTask.key!);
    }
    // delete task in the db
    await updateDateListInCloud(tmpList);
  }

  @override
  Future updateDateListInCloud(MyList updatedList) async {
    if (uid == null) {
      throw ('\x1B[31mError #6[updating task]: User not signed in.\x1B[0m');
    } else {
      final listDocRef = db.collection('user_lists').doc(uid).collection('date_lists').doc(updatedList.id);
      Map<String, dynamic> formattedUpdatedList = formatMyListToFirebaseList(updatedList);

      await listDocRef.set(formattedUpdatedList).onError((error, stackTrace) {
        log('\x1B[31mError #6[updating task]: $error\x1B[0m');
        Logger(printer: PrettyPrinter(colors: false)).e('Error #6[updating task]: $error');
      });
      // log('\x1B[33m3. updatedList\x1B[0m');
      // debugPrint(formattedUpdatedList.toString());
    }
  }

  @override
  Future createIdList(String title) {
    final listCollectionRef = db.collection("user_lists").doc(uid).collection('id_lists');
    return listCollectionRef.add({
      'title': title,
    }).then((value) {
      log('\x1B[33madded a new list: $title\x1B[0m');
    }, onError: (e) {
      log('\x1B[31mError #3[adding list]: $e\x1B[0m');
      Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding list]: $e\x1B[0m');
    });
  }

  @override
  Future addTaskToDateListInCloud(MyTask myTask, DateTime date) async {
    if (uid == null) {
      throw ('Error #1[adding task]: User not signed in.');
    } else {
      String listDateId = DateFormat('yyyy-MM-dd').format(date);
      final listDocRef = db.collection("user_lists").doc(uid).collection('date_lists').doc(listDateId);

      final formattedTask = formatMyTaskToFirebaseTask(myTask);

      await listDocRef.set({
        'todoes': FieldValue.arrayUnion([formattedTask])
      }, SetOptions(merge: true)).then((value) {
        // log('\x1B[33madded a new task: $formattedTask\x1B[0m');
      }, onError: (e) {
        log('\x1B[31mError #3[adding task]: $e\x1B[0m');
        Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding task]: $e\x1B[0m');
      });
    }
  }

  @override
  Map<String, dynamic> formatMyTaskToFirebaseTask(MyTask myTask) => myTask.isDefault
      ? {
          'default_todo': myTask.isDefault,
          'title': myTask.title,
          'completed': myTask.isCompleted,
          'start_time': DateTimeUtils.convertDateTimeToTimestamp(myTask.startTime),
          'end_time': DateTimeUtils.convertDateTimeToTimestamp(myTask.endTime),
        }
      : {
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
      'todoes': firebaseTasks,
      'completed_todoes': firebaseCompletedTasks,
    };
    // log('\x1B[37m2. formattedList: $firebaseList  \x1B[0m');

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
            isDefault: value['default_todo'] ?? false,
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
      myList.tasks = convertFirebaseTasksToMyListItems(firebaseList['todoes']);
      myList.completedTasks = convertFirebaseTasksToMyListItems(firebaseList['completed_todoes']);
      return myList;
    }
  }
}
