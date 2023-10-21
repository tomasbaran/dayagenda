import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:dayagenda/screens/tasks_screen.dart';
import 'package:dayagenda/services/service_locator.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/style/theme.dart';

class MyMaterialApp extends StatelessWidget {
  MyMaterialApp({
    super.key,
  });

  final appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appState.navigatorKey,
      theme: AppTheme.light,
      title: 'DayAgenda',
      // onGenerateRoute (instead of home) is necessary for the showCupertinoModalBottomSheet to animate and shrink the background when adding a new task
      onGenerateRoute: (RouteSettings settings) {
        switch (settings.name) {
          case '/':
            return MaterialWithModalsPageRoute(
              builder: (_) => const TasksScreen(),
              settings: settings,
            );
        }
        return null;
      },
    );
  }
}
