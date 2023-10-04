import 'package:today/services/auth_service/auth_service.dart';
import 'package:today/services/service_locator.dart';

class AuthState {
  final AuthService authService = getIt<AuthService>();

  Future loginWithEmailAndPassword(String email, String password) async {
    await authService.loginWithEmailAndPassword(email, password);
  }

  Future signupByConvertingAnonymousUserToPermanentUser(String email, String password) async {
    await authService.signupByConvertingAnonymousUserToPermanentUser(email, password);
  }

  Future signInAnonymously() async {
    await authService.signInAnonymously();
  }

  Future logout() async {
    await authService.logout();
  }
}
