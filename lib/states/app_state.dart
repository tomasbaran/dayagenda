import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayagenda/services/firebase_analytics_service.dart';
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
import 'package:universal_platform/universal_platform.dart';

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
      ((UniversalPlatform.isIOS || UniversalPlatform.isAndroid) ? mobileCompletedTitleBottomPadding : desktopCompletedTitleBottomPadding) -
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
    } else {
      FirebaseAnalyticsService.analytics.setUserId(id: authService.uid);
      MixpanelService.mixpanel?.identify(authService.uid!);

      log(
        time: DateTime.now(),
        '\x1B[33m${authService.uid}\x1B[0m',
        name: 'signed in as',
      );
    }
  }

  void addDefaultTasks() async {
    final listState = getIt<ListState>();

    // create id list called Instructions
    final DocumentReference instructionsList = await listState.createNewIdList(title: 'Instructions');
    log('instructionsList: ${instructionsList.id}');
    // Yesterday
    // listState.selectDateListByDate(DateTime.now().subtract(const Duration(days: 1)));
    // await listState.addTaskToDateList(MyTask(isDefault: true, title: 'Tap on the pushpin icon to go back to today'), trackInMixpanel: false);

    // Tomorrow
    listState.selectDateListByDate(DateTime.now().add(const Duration(days: 1)));
    await listState.addTaskToList(
        MyTask(
          idList: instructionsList.id,
          isDefault: true,
          title: 'Tap the paper-like icon below to return and see TODAY\'s tasks',
        ),
        dateList: listState.dateState.selectedDate.value,
        trackInMixpanel: false);
    // await listState.addTaskToDateList(MyTask(isDefault: true, title: 'Send feedback by going into my account tab'), trackInMixpanel: false);
    // await listState.addTaskToDateList(MyTask(isDefault: true, title: 'Sign up to have all my tasks synced on the web'), trackInMixpanel: false);

    // Today
    listState.selectDateListByDate(DateTime.now());

    // 8.
    // await listState.addTaskToDateList(
    //     MyTask(
    //         isDefault: true,
    //         title: 'Tap the Share icon on desktop Safari & select Add to Dock to install on mac',
    //         startTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour, DateTime.now().minute, 00),
    //         endTime: DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day, DateTime.now().hour,
    //             DateTime.now().minute + 5 > 60 ? 55 : DateTime.now().minute + 5, 59)),
    //     trackInMixpanel: false);

    // 7.
    // await listState.addTaskToDateList(MyTask(isDefault: true, title: 'Tap the iOS Share icon at the bottom & select Add to Home Screen to install'),
    //     trackInMixpanel: false);

    // 6.
    // await listState.addTaskToDateList(MyTask(isDefault: true, title: 'Hit the plus icon to create a new task'), trackInMixpanel: false);

    // 5.
    // await listState.addTaskToDateList(MyTask(isDefault: true, title: 'Tap on the calendar icon to switch to tomorrow'), trackInMixpanel: false);

    // 4.
    await listState.addTaskToList(MyTask(isDefault: true, title: 'Swipe left to see tasks scheduled for tomorrow'), trackInMixpanel: false);

    // 3.
    await listState.addTaskToList(MyTask(isDefault: true, title: 'Tap the double arrow icon on the right to move this instruction to the next day'),
        trackInMixpanel: false);

    // 2.
    await listState.addTaskToList(MyTask(isDefault: true, title: 'Long-press this instruction & drag down to deprioritize'), trackInMixpanel: false);

    // 1.`

    await listState.addTaskToList(MyTask(isDefault: true, title: 'Tick the box on the left to mark this instruction as complete'),
        trackInMixpanel: false);

    FirebaseAnalyticsService.analytics.logEvent(name: 'add_default_tasks');
    MixpanelService.mixpanel?.track('Add Default Todoes');
  }

  Future<void> initializeSelectedFlavor() async {
    final selectedFlavor = await Flavor.selected();
    debugPrint("Connecting to ${selectedFlavor.name} environment (${selectedFlavor.baseUrl})...");

    await dotenv.load(fileName: "lib/dotenv");
    switch (selectedFlavor) {
      case FlavorType.dev:
        await Firebase.initializeApp(name: kIsWeb ? null : 'dev', options: dev.DefaultFirebaseOptions.currentPlatform);
        FirebaseAnalyticsService.analytics.setAnalyticsCollectionEnabled(true);
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
