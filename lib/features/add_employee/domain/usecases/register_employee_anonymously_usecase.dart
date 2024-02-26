import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/states/auth_state.dart';

class RegisterEmployeesAnonymouslyUsecase {
  final AuthService repository;

  RegisterEmployeesAnonymouslyUsecase(this.repository);

  Future call(List<Employee> employees) async {
    final authState = locate<AuthState>();
    final appState = locate<AppState>();
    // step 1: logout: to be able to use signInAnonymously for the employees
    await repository.logout();

    // step 2: register employees
    for (var employee in employees) {
      final employeeCredentials = await repository.signInAnonymously();
      final employeeUid = employeeCredentials?.user?.uid;
      print('registerEmployeeAnonymously employeeUid: $employeeUid');
    }
    // step 3: log back in the owner
    final lastUsedEmail = authState.lastUsedEmail;
    final lastUsedPassword = authState.lastUsedPassword;
    if (lastUsedPassword == null || lastUsedEmail == null) {
      appState.updateNavBarSelection(NavBarSelection.account);
    } else {
      await repository.loginWithEmailAndPassword(lastUsedEmail, lastUsedPassword);
    }
  }
}
