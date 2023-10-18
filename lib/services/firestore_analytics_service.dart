import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:today/models/my_task.dart';
import 'package:today/services/auth_service/auth_service.dart';
import 'package:today/services/service_locator.dart';

class FirestoreAnalyticsService {
  final db = FirebaseFirestore.instance;
  String? get uid => getIt<AuthService>().uid;

  Future updateUserStatOnAdded(MyTask myTask) async {
    if (myTask.isDefault) {
      await increaseUserStat('default_todoes_counter');
    } else {
      await increaseUserStat('todoes_counter');
    }
  }

  Future updateUserStatOnCompleted(MyTask myTask) async {
    if (myTask.isDefault) {
      await decreaseUserStat('default_todoes_counter');
    } else {
      if (myTask.startTime != null) {
        await increaseUserStat('completed_events_counter');
      } else {
        await increaseUserStat('completed_tasks_counter');
      }
      await updateTasksEventsRatio();
    }
  }

  Future updateTasksEventsRatio() async {
    final listDocRef = db.collection('user_stats').doc(uid);
    listDocRef.get().then((value) {
      final userStats = value.data() as Map;
      final completedTasks = userStats['completed_tasks_counter'] ?? 1;
      final completedEvents = userStats['completed_events_counter'] ?? 1;
      final ratio = completedTasks / completedEvents;
      // log('completedTasks: $completedTasks');
      // log('completedEvents: $completedEvents');
      // log('ratio: $ratio');
      listDocRef.set({'ratio_tasks-events(completed)': double.parse(ratio.toStringAsFixed(1))}, SetOptions(merge: true)).then((value) {},
          onError: (e) {
        log('\x1B[31mError #4[updateTasksEventsRation]: $e\x1B[0m');
        Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
      });
    }, onError: (e) {
      log('\x1B[31mError #3[adding stat]: $e\x1B[0m');
      Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
    });
  }

  Future increaseUserStat(String statTitle) async {
    final listDocRef = db.collection('user_stats').doc(uid);
    await listDocRef.set({statTitle: FieldValue.increment(1)}, SetOptions(merge: true)).then((value) {
      // log('\x1B[33madded a new stat: $statTitle\x1B[0m');
    }, onError: (e) {
      log('\x1B[31mError #3[adding stat]: $e\x1B[0m');
      Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
    });
  }

  Future decreaseUserStat(String statTitle) async {
    final listDocRef = db.collection('user_stats').doc(uid);
    await listDocRef.set({statTitle: FieldValue.increment(-1)}, SetOptions(merge: true)).then((value) {
      // log('\x1B[33madded a new stat: $statTitle\x1B[0m');
    }, onError: (e) {
      log('\x1B[31mError #3[adding stat]: $e\x1B[0m');
      Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
    });
  }
}
