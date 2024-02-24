import 'package:dayagenda/core/app_router.dart';
import 'package:flutter/material.dart';
import 'package:dayagenda/services/service_locator.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/style/theme.dart';

class MyMaterialApp extends StatelessWidget {
  MyMaterialApp({
    super.key,
  });

  final appState = getIt<AppState>();

  // GoRouter configuration
  final _router = AppRouter.createRouter();

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      // navigatorKey: appState.navigatorKey,
      theme: AppTheme.light,
      title: 'DayAgenda',
      // onGenerateRoute (instead of home) is necessary for the showCupertinoModalBottomSheet to animate and shrink the background when adding a new task
      routerConfig: _router,
    );
  }
}
