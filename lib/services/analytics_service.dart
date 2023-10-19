import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:today/globals/constants.dart';
import 'package:today/models/my_task.dart';
import 'package:today/services/auth_service/auth_service.dart';
import 'package:today/services/mixpanel_service.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/utils/date_time_utils.dart';

class AnalyticsService {
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
        MixpanelService.mixpanel?.track('Complete Todo', properties: {'type': 'event'});
      } else {
        await increaseUserStat('completed_tasks_counter');
        MixpanelService.mixpanel?.track('Complete Todo', properties: {'type': 'task'});
      }
      await updateTasksEventsRatio();
      await updateCompletionRate();
    }
  }

  Future updateTasksEventsRatio() async {
    final listDocRef = db.collection('user_stats').doc(uid);
    await listDocRef.get().then((value) {
      final userStats = value.data() as Map;
      final completedTasks = userStats['completed_tasks_counter'] ?? 1;
      final completedEvents = userStats['completed_events_counter'] ?? 1;
      final ratio = completedTasks / completedEvents;
      // log('completedTasks: $completedTasks');
      // log('completedEvents: $completedEvents');
      // log('ratio: $ratio');

      MixpanelService.mixpanel?.getPeople().set('ratio_tasks-events(completed)', double.parse(ratio.toStringAsFixed(1)));

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
    MixpanelService.mixpanel?.getPeople().increment(statTitle, 1);
  }

  Future decreaseUserStat(String statTitle) async {
    final listDocRef = db.collection('user_stats').doc(uid);
    await listDocRef.set({statTitle: FieldValue.increment(-1)}, SetOptions(merge: true)).then((value) {
      // log('\x1B[33madded a new stat: $statTitle\x1B[0m');
    }, onError: (e) {
      log('\x1B[31mError #3[adding stat]: $e\x1B[0m');
      Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
    });

    await listDocRef.get().then((value) {
      final userStats = value.data() as Map;
      final defaultTodoesCounter = userStats['default_todoes_counter'] ?? 100;
      if (defaultTodoesCounter == 0) {
        MixpanelService.mixpanel?.track('Default Tasks Completed');
      }
    }, onError: (e) {
      log('\x1B[31mError #3[adding stat]: $e\x1B[0m');
      Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
    });

    MixpanelService.mixpanel?.getPeople().increment(statTitle, -1);
  }

  Future writeSignupDate() async {
    final listDocRef = db.collection('user_stats').doc(uid);
    MixpanelService.mixpanel?.getPeople().setOnce('anonymously_signed_up', DateTimeUtils.mixpanelNow());

    await listDocRef.set({'anonymously_signed_up': DateTime.now()}, SetOptions(merge: true)).then((value) {}, onError: (e) {
      log('\x1B[31mError #3[adding stat]: $e\x1B[0m');
      Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
    });
  }

  Future crawlFutureDays(int numberOfDays) async {
    final listDocRef = db.collection('user_lists').doc(uid);
    int crawledTodoes = 0;

    for (int daysI = 0; daysI < numberOfDays; daysI++) {
      final date = DateTime.now().add(Duration(days: daysI));
      String listDateId = DateFormat('yyyy-MM-dd').format(date);
      final dateDocRef = listDocRef.collection('date_lists').doc(listDateId);

      await dateDocRef.get().then((value) {
        final Map? dateList = value.data();
        final tasks = dateList?['tasks'] as List? ?? [];
        for (final task in tasks) {
          if (task['default_task'] == null) {
            log('task[$listDateId]: ${task['title']}');
            crawledTodoes++;
          }
        }
        log('crawledTodoes: $crawledTodoes');
      }, onError: (e) {
        log('\x1B[31mError #6[crawl next days]: $e\x1B[0m');
        Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
      });
    }
    return crawledTodoes;
  }

  Future updateCompletionRate() async {
    final listDocRef = db.collection('user_stats').doc(uid);
    await listDocRef.get().then((value) async {
      final userStats = value.data() as Map;
      final completedTasks = userStats['completed_tasks_counter'] ?? 0;
      final completedEvents = userStats['completed_events_counter'] ?? 0;
      final allTodoes = userStats['todoes_counter'] ?? 0;
      double completionRate;
      if (allTodoes == 0) {
        completionRate = 0;
      } else {
        final notCompletedFutureTodoes = await crawlFutureDays(futureDaysToCrawl);
        completionRate = ((completedTasks + completedEvents) / (allTodoes - notCompletedFutureTodoes)) * 100;
        completionRate = double.parse(completionRate.toStringAsFixed(0));
      }

      // log('completedTasks: $completedTasks');
      // log('completedEvents: $completedEvents');
      // log('allTodoes: $allTodoes');
      // log('rate: $completionRate');

      MixpanelService.mixpanel?.getPeople().set('completion_rate', completionRate);

      listDocRef.set({'completion_rate': completionRate}, SetOptions(merge: true)).then((value) {}, onError: (e) {
        log('\x1B[31mError calcCompletionRate: $e\x1B[0m');
        Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
      });
    }, onError: (e) {
      log('\x1B[31mError #3[adding stat][calcCompletionRate]: $e\x1B[0m');
      Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
    });
  }

  Future updateActivityStats() async {
    final listDocRef = db.collection('user_stats').doc(uid);

    await listDocRef.get().then((value) async {
      final userStats = value.data() as Map;
      final signupDate = userStats['anonymously_signed_up'] as Timestamp?;
      final now = DateTime.now();
      final difference = now.difference(signupDate?.toDate() ?? now);
      final activePeriod = difference.inDays;
      final completedTodoes = userStats['todoes_counter'] ?? 0;
      final completedTodoesPerDay = completedTodoes / (activePeriod == 0 ? 1 : activePeriod);

      MixpanelService.mixpanel?.getPeople().set('active_period', activePeriod);
      MixpanelService.mixpanel?.getPeople().set('last_signed_in', DateTimeUtils.mixpanelNow());
      MixpanelService.mixpanel?.getPeople().set('completed_todoes_per_day', double.parse(completedTodoesPerDay.toStringAsFixed(0)));

      await listDocRef.set({
        'active_period': activePeriod,
        'last_signed_in': DateTime.now(),
        'completed_todoes_per_day': double.parse(completedTodoesPerDay.toStringAsFixed(0)),
      }, SetOptions(merge: true)).then((value) {}, onError: (e) {
        log('\x1B[31mError #3[adding stat]: $e\x1B[0m');
        Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
      });
    }, onError: (e) {
      log('\x1B[31mError #3[adding stat]: $e\x1B[0m');
      Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
    });
  }
}
