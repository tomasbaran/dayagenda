import 'package:dayagenda/features/employee_registration/presentation/screens/register_employee_screen.dart';
import 'package:dayagenda/screens/tasks_screen.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            return const TasksScreen();
          },
        ),
        GoRoute(
            path: '/register_employee/:uid',
            builder: (context, state) {
              final uid = state.pathParameters['uid'] ?? 'unknown';
              return RegisterEmployeeScreen(uid: uid);
            }),
      ],
    );
  }
}
