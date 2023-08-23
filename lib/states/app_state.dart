import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:today/firebase_options.dart';
import 'package:today/globals/constants.dart';
import 'package:today/services/auth_service/auth_service.dart';
import 'package:today/models/enums.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';

class AppState {
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

  Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final authService = getIt<AuthService>();

    // DEV-MODE:
    // check whether the user is signed in
    if (authService.uid == null) {
      log(
        time: DateTime.now(),
        '${DateTime.now().minute}:${DateTime.now().second} NOT signed in',
      );
      await authService.signInAnonymously();
      log(
        time: DateTime.now(),
        'signed in as: ${authService.uid}\x1B[0m',
      );
    } else {
      log(
        time: DateTime.now(),
        'signed in as: ${authService.uid}\x1B[0m',
      );
    }
  }
}
