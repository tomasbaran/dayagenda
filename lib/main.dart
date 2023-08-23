import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:today/screens/tasks_screen.dart';
import 'package:today/services/auth_service/auth_service.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/states/app_state.dart';
import 'style/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  setupGetIt();

  final appState = getIt<AppState>();
  await appState.initialize();

  runApp(TodayApp());
}

class TodayApp extends StatelessWidget {
  TodayApp({super.key});

  final authService = getIt<AuthService>();
  final appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appState.navigatorKey,
      theme: AppTheme.light,
      title: 'DayAgenda',
      // home: Auth().uid == null ? LoginScreen() : const TasksScreen(),
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
