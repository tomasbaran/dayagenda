import 'package:dayagenda/features/add_employee/presentation/screens/register_employee_screen.dart';
import 'package:dayagenda/screens/tasks_screen.dart';
import 'package:dayagenda/widgets/email_signup_form_container.dart';
import 'package:go_router/go_router.dart';

class AppRouter {
  static GoRouter createRouter() {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) {
            // RELEASE-MODE:
            // return const TasksScreen();
            // DEV-MODE:
            return RegisterEmployeeScreen(uid: 'ANzdFI6cqiU5X6ut8JFWSQp4jVE2');
          },
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) {
            return const EmailFormContainer.signup();
          },
        ),
        // DEV-MODE:
        GoRoute(
          path: '/dev',
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
