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

  signUpFirstTimeUserAnonymously() async {
    final authService = getIt<AuthService>();

    if (authService.uid == null) {
      await authService.signInAnonymously();
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

  Future<void> initialize() async {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    listenToAuthChanges();

    await signUpFirstTimeUserAnonymously();
  }
}
