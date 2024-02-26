import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/states/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterEmployeesAnonymouslyUsecase {
  final AuthService repository;

  RegisterEmployeesAnonymouslyUsecase(this.repository);

  Future<UserCredential> call() async {
    final authState = locate<AuthState>();
    final AppState appState = locate<AppState>();
    await repository.logout();
    final result = await repository.signInAnonymously();
    final lastUsedEmail = authState.lastUsedEmail;
    final lastUsedPassword = authState.lastUsedPassword;
    if (lastUsedPassword == null || lastUsedEmail == null) {
      appState.updateNavBarSelection(NavBarSelection.account);
    } else {
      await repository.loginWithEmailAndPassword(lastUsedEmail, lastUsedPassword);
    }
    return result;
  }
}
