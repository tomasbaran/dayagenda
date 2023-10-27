import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';
import 'package:dayagenda/globals/constants.dart';
import 'package:dayagenda/models/my_task.dart';
import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/services/mixpanel_service.dart';
import 'package:dayagenda/services/service_locator.dart';
import 'package:dayagenda/utils/date_time_utils.dart';

class AnalyticsService {
  final db = FirebaseFirestore.instance;
  String? get uid => getIt<AuthService>().uid;

  Future updateUserStatOnAddedTodo(MyTask myTask, DateTime taskDate) async {
    if (myTask.isDefault) {
      await increaseUserStat('default_todoes_counter');
    } else {
      await increaseUserStat('todoes_counter');
      // if the task is today+, increase the not completed future todoes counter (needed for completion rate purpose)
      if (taskDate.isAfter(DateTime.now()) || taskDate == DateTimeUtils.resetTimeToZero(DateTime.now())) {
        await increaseUserStat('not_completed_future_todoes_counter');
      }
    }
  }

  Future updateUserStatOnCompletedTodo(MyTask myTask, DateTime taskDate) async {
    if (myTask.isDefault) {
      await decreaseUserStat('default_todoes_counter');
    } else {
      await increaseUserStat('completed_todoes_counter');
      // if the task is today+, increase the not completed future todoes counter (needed for completion rate purpose)
      if (taskDate.isAfter(DateTime.now()) || taskDate == DateTimeUtils.resetTimeToZero(DateTime.now())) {
        await decreaseUserStat('not_completed_future_todoes_counter');
      }

      if (myTask.startTime != null) {
        await increaseUserStat('completed_events_counter');
        MixpanelService.mixpanel?.track('Complete Todo', properties: {'type': 'event'});
      } else {
        await increaseUserStat('completed_tasks_counter');
        MixpanelService.mixpanel?.track('Complete Todo', properties: {'type': 'task'});
      }
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
        final tasks = dateList?['todoes'] as List? ?? [];
        for (final task in tasks) {
          if (task['default_todo'] == null) {
            crawledTodoes++;
          }
        }
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
      final completedTodoes = userStats['completed_todoes_counter'] ?? 0;
      final allTodoes = userStats['todoes_counter'] ?? 0;
      double completionRate;
      if (allTodoes == 0) {
        completionRate = 0;
      } else {
        final notCompletedFutureTodoes = await crawlFutureDays(futureDaysToCrawl);
        completionRate = (completedTodoes / (allTodoes - notCompletedFutureTodoes)) * 100;
        completionRate = double.parse(completionRate.toStringAsFixed(0));

        log('allTodoes: $allTodoes');
        log('notCompletedFutureTodoes: $notCompletedFutureTodoes');
        log('rate: $completionRate');
      }

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

  Future updateActivityStatsOnAppLaunch() async {
    final listDocRef = db.collection('user_stats').doc(uid);

    await listDocRef.get().then((value) async {
      final userStats = value.data() as Map;
      final signupDate = userStats['anonymously_signed_up'] as Timestamp?;
      // last_used
      final now = DateTime.now();

      // active_period
      final difference = now.difference(signupDate?.toDate() ?? now);
      final activePeriod = difference.inDays;

      // completed_todoes_per_day
      final completedTodoes = userStats['completed_todoes_counter'] ?? 0;
      final completedTodoesPerDay = completedTodoes / (activePeriod == 0 ? 1 : activePeriod);

      log('activePeriod: $activePeriod');
      log('last_used: ${DateTimeUtils.mixpanelNow()}');
      log('completed_todoes_per_day: ${completedTodoesPerDay.toStringAsFixed(0)}');

      try {
        MixpanelService.mixpanel?.getPeople().set('last_used', DateTimeUtils.mixpanelNow());
        MixpanelService.mixpanel?.getPeople().set('active_period', activePeriod);
        MixpanelService.mixpanel?.getPeople().set('completed_todoes_per_day', double.parse(completedTodoesPerDay.toStringAsFixed(0)));
        log('mixpanel updated: ${DateTimeUtils.mixpanelNow()}, $activePeriod, ${completedTodoesPerDay.toStringAsFixed(0)}');
      } catch (e) {
        log('\x1B[31mError #3[adding stat]: $e\x1B[0m');
        Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[updating mixpanel]: $e\x1B[0m');
      }

      await listDocRef.set({
        'last_used': now,
        'active_period': activePeriod,
        'completed_todoes_per_day': double.parse(completedTodoesPerDay.toStringAsFixed(0)),
      }, SetOptions(merge: true)).then((value) {}, onError: (e) {
        log('\x1B[31mError #3[adding stat]: $e\x1B[0m');
        Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
      });
    }, onError: (e) {
      log('\x1B[31mError #3[adding stat]: $e\x1B[0m');
      Logger(printer: PrettyPrinter(colors: false)).e('\x1B[31mError #3[adding stat]: $e\x1B[0m');
    });

    await updateTasksEventsRatio();
  }
}
