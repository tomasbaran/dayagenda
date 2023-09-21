import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:today/firebase_options.dart';
import 'package:today/globals/constants.dart';
import 'package:today/models/my_task.dart';
import 'package:today/services/auth_service/auth_service.dart';
import 'package:today/models/enums.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/states/list_state/list_state.dart';
import 'package:today/style/style_constants.dart';

class AppState {
  final isSignedIn = ValueNotifier<bool>(false);

  final navigatorKey = GlobalKey<NavigatorState>();
  final navBar = ValueNotifier<NavBarSelection>(NavBarSelection.unselected);
  updateNavBarSelection(NavBarSelection newNavBarSelection) => navBar.value = newNavBarSelection;

  double screenHeight = 0;
  EdgeInsets safeArea = EdgeInsets.zero;

  getScreenMeasurments(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    safeArea = MediaQuery.of(context).padding;
  }

  double emptySpaceHeight(int taskCount) =>
      screenHeight -
      safeArea.top - //iOS status bar
      AppBar().preferredSize.height - //appBar's height
      (taskCount * taskCardHeight) -
      completedTitleHeight -
      completedTitleBottomPadding -
      floatingBottomSafeArea;

  double get floatingBottomSafeArea => safeArea.bottom + floatingNavBarContainerHeight + 4;

  final datePageController = PageController(initialPage: todayIndex, viewportFraction: 0.95);

  listenToAuthChanges() {
    final authService = getIt<AuthService>();

    authService.myAuthSubscription().onData((data) {
      log('new data:$data ');
      if (data == null) {
        // print('User is currently signed out!');
        isSignedIn.value = false;
      } else {
        // print('User is signed in!');
        if (data.email != null) {
          isSignedIn.value = true;
        } else {
          isSignedIn.value = false;
        }
      }
    });
  }

  checkWhetherToSignUpFirstTimeUserAnonymously() async {
    final authService = getIt<AuthService>();

    if (authService.uid == null) {
      await authService.signInAnonymously();
      addDefaultTasks();
      log(
        time: DateTime.now(),
        'signed up anonymously as: ${authService.uid}\x1B[0m',
      );
    } else {
      log(
        time: DateTime.now(),
        'signed in as: ${authService.uid}\x1B[0m',
      );
    }
  }

  void addDefaultTasks() async {
    final listState = getIt<ListState>();

    listState.selectDateListByDate(DateTime.now().subtract(const Duration(days: 1)));
    await listState.addTaskToDateList(MyTask(title: 'Tap on the pushpin icon to go back to today'));

    listState.selectDateListByDate(DateTime.now().add(const Duration(days: 1)));
    await listState.addTaskToDateList(MyTask(title: 'Send feedback by going into my account tab'));
    await listState.addTaskToDateList(MyTask(title: 'Sign up to have all my tasks synced also on the web'));

    listState.selectDateListByDate(DateTime.now());

    await listState.addTaskToDateList(MyTask(
        title: 'Review today\'s tasks',
        startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 20, 00, 00),
        endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 20, 10, 00)));

    await listState.addTaskToDateList(MyTask(title: 'Add new task with by tapping on the + icon'));

    await listState.addTaskToDateList(MyTask(title: 'Hold me to reorder me'));

    await listState.addTaskToDateList(MyTask(title: 'Tap on me to edit me'));

    await listState.addTaskToDateList(MyTask(title: 'Tap on the calendar icon to switch to tomorrow'));

    await listState.addTaskToDateList(MyTask(title: 'Swipe to the left to see yesterday\'s unfinished tasks'));
  }

  Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    listenToAuthChanges();

    await checkWhetherToSignUpFirstTimeUserAnonymously();
  }
}
