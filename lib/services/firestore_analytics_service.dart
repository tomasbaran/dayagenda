import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import 'package:today/models/my_task.dart';
import 'package:today/services/auth_service/auth_service.dart';
import 'package:today/services/service_locator.dart';

class FirestoreAnalyticsService {
  final db = FirebaseFirestore.instance;
  String? get uid => getIt<AuthService>().uid;

  trackUserStatOnAdded(MyTask myTask) {
    if (myTask.isDefault) {
      increaseUserStat('default_todoes_counter');
    } else {
      increaseUserStat('added_todoes_counter');
    }
  }

  trackUserStatOnCompleted(MyTask myTask) {
    if (myTask.isDefault) {
      decreaseUserStat('default_todoes_counter');
    } else if (myTask.startTime != null) {
      increaseUserStat('completed_events_counter');
    } else {
      increaseUserStat('completed_tasks_counter');
    }
  }

  increaseUserStat(String statTitle) {
    final listDocRef = db.collection('user_stats').doc(uid);
    listDocRef.set({statTitle: FieldValue.increment(1)}, SetOptions(merge: true)).then((value) {
      log('\x1B[33madded a new stat: $statTitle\x1B[0m');
    }, onError: (e) {
      log('\x1B[31mError #3[adding stat]: $e\x1B[0m');
      Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
    });
  }

  decreaseUserStat(String statTitle) {
    final listDocRef = db.collection('user_stats').doc(uid);
    listDocRef.set({statTitle: FieldValue.increment(-1)}, SetOptions(merge: true)).then((value) {
      log('\x1B[33madded a new stat: $statTitle\x1B[0m');
    }, onError: (e) {
      log('\x1B[31mError #3[adding stat]: $e\x1B[0m');
      Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
    });
  }
}
