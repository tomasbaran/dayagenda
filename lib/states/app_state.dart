import 'dart:developer';

import 'package:dayagenda/utils/screen_utlis.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dayagenda/flavor.dart';
import 'package:dayagenda/globals/constants.dart';
import 'package:dayagenda/models/my_task.dart';
import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/services/analytics_service.dart';
import 'package:dayagenda/services/mixpanel_service.dart';
import 'package:dayagenda/services/service_locator.dart';
import 'package:dayagenda/states/auth_state.dart';
import 'package:dayagenda/states/list_state/list_state.dart';
import 'package:dayagenda/style/style_constants.dart';

import 'package:dayagenda/firebase_options_dev.dart' as dev;
import 'package:dayagenda/firebase_options_live.dart' as live;

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

  double emptySpaceHeight(int taskCount, BuildContext context) =>
      screenHeight -
      safeArea.top - //iOS status bar
      AppBar().preferredSize.height - //appBar's height
      (taskCount * taskCardHeight) -
      completedTitleHeight -
      (ScreenUtils.isMobile(context) ? mobileCompletedTitleBottomPadding : desktopCompletedTitleBottomPadding) -
      floatingBottomSafeArea;

  double get floatingBottomSafeArea => safeArea.bottom + floatingNavBarContainerHeight + 4;

  final datePageController = PageController(initialPage: todayIndex, viewportFraction: 1);

  listenToAuthChanges() {
    final authService = getIt<AuthService>();

    authService.myAuthSubscription().onData((data) {
      // log('new data:$data ');
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
    final authState = getIt<AuthState>();

    if (authService.uid == null) {
      await authState.signInAnonymously();
      addDefaultTasks();
      log(
        time: DateTime.now(),
        'signed up anonymously as: ${authService.uid}\x1B[0m',
      );
    } else {
      log(
        time: DateTime.now(),
        '\x1B[33m${authService.uid}\x1B[0m',
        name: 'signed in as',
      );
    }
  }

  void addDefaultTasks() async {
    final listState = getIt<ListState>();

    // Yesterday
    listState.selectDateListByDate(DateTime.now().subtract(const Duration(days: 1)));
    await listState.addTaskToDateList(MyTask(isDefault: true, title: 'Tap on the pushpin icon to go back to today'), trackInMixpanel: false);

    // Tomorrow
    listState.selectDateListByDate(DateTime.now().add(const Duration(days: 1)));
    await listState.addTaskToDateList(MyTask(isDefault: true, title: 'Send feedback by going into my account tab'), trackInMixpanel: false);
    await listState.addTaskToDateList(MyTask(isDefault: true, title: 'Sign up to have all my tasks synced on the web'), trackInMixpanel: false);

    // Today
    listState.selectDateListByDate(DateTime.now());

    // 7.
    await listState.addTaskToDateList(
        MyTask(
            isDefault: true,
            title: 'Review today\'s tasks',
            startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 20, 00, 00),
            endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, 20, 10, 00)),
        trackInMixpanel: false);

    // 6.
    await listState.addTaskToDateList(MyTask(isDefault: true, title: 'Add a new to-do by tapping on the + icon'), trackInMixpanel: false);

    // 5.
    await listState.addTaskToDateList(MyTask(isDefault: true, title: 'Tap on the calendar icon to switch to tomorrow'), trackInMixpanel: false);

    // 4.
    await listState.addTaskToDateList(MyTask(isDefault: true, title: 'Swipe to the left to see yesterday\'s unfinished tasks'),
        trackInMixpanel: false);

    // 3.
    await listState.addTaskToDateList(MyTask(isDefault: true, title: 'Hold me (drag handles on the web) to reorder me'), trackInMixpanel: false);

    // 2.
    await listState.addTaskToDateList(MyTask(isDefault: true, title: 'Tap on me to edit me'), trackInMixpanel: false);

    // 1.`
    await listState.addTaskToDateList(MyTask(isDefault: true, title: 'Mark me as completed by tapping on the checkbox'), trackInMixpanel: false);

    MixpanelService.mixpanel?.track('Add Default Tasks');
  }

  Future<void> initializeSelectedFlavor() async {
    final selectedFlavor = await Flavor.selected();
    debugPrint("Connecting to ${selectedFlavor.name} environment (${selectedFlavor.baseUrl})...");

    await dotenv.load(fileName: "lib/dotenv");
    switch (selectedFlavor) {
      case FlavorType.dev:
        await Firebase.initializeApp(name: kIsWeb ? null : 'dev', options: dev.DefaultFirebaseOptions.currentPlatform);
        await MixpanelService.initMixpanel(dotenv.get('MIXPANEL_TOKEN_DEV'));
        break;
      case FlavorType.live:
        await Firebase.initializeApp(name: kIsWeb ? null : 'live', options: live.DefaultFirebaseOptions.currentPlatform);
        await MixpanelService.initMixpanel(dotenv.get('MIXPANEL_TOKEN_LIVE'));

        break;
      default:
        throw Exception("Unknown environment $selectedFlavor");
    }

    listenToAuthChanges();

    await checkWhetherToSignUpFirstTimeUserAnonymously();

    try {
      await AnalyticsService().updateActivityStatsOnAppLaunch();
    } catch (e) {
      log('Error firestore analytics: $e');
    }
  }
}
