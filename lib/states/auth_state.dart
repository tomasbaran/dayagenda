import 'package:today/services/auth_service/auth_service.dart';
import 'package:today/services/mixpanel_service.dart';
import 'package:today/services/service_locator.dart';

class AuthState {
  final AuthService authService = getIt<AuthService>();

  Future loginWithEmailAndPassword(String email, String password) async {
    await authService.loginWithEmailAndPassword(email, password);
    MixpanelService.mixpanel?.track('Login', properties: {'email': email});
  }

  Future signupByConvertingAnonymousUserToPermanentUser(String email, String password) async {
    await authService.signupByConvertingAnonymousUserToPermanentUser(email, password);
    MixpanelService.mixpanel?.getPeople().set('\$email', email);
    MixpanelService.mixpanel?.track('Signup With Email', properties: {'email': email});
  }

  Future signInAnonymously() async {
    await authService.signInAnonymously();
    MixpanelService.mixpanel?.track('Signup Anonymously');
  }

  Future logout() async {
    await authService.logout();
    MixpanelService.mixpanel?.track('Logout');
  }
}
