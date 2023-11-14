import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/services/mixpanel_service.dart';
import 'package:dayagenda/services/service_locator.dart';
import 'package:flutter/material.dart';

class AuthState {
  final AuthService authService = getIt<AuthService>();

  Future loginWithEmailAndPassword(String email, String password) async {
    await authService.loginWithEmailAndPassword(email, password);
    debugPrint("Signed in with email: $email [${authService.uid}]");

    MixpanelService.mixpanel?.identify(authService.uid!);
    MixpanelService.mixpanel?.getPeople().set('\$email', email);
    MixpanelService.mixpanel?.track('Login', properties: {'email': email});
  }

  Future signupByConvertingAnonymousUserToPermanentUser(String email, String password) async {
    await authService.signupByConvertingAnonymousUserToPermanentUser(email, password);
    debugPrint("Converted anonymous user with email: $email [${authService.uid}]");

    MixpanelService.mixpanel?.getPeople().set('\$email', email);
    MixpanelService.mixpanel?.track('Signup With Email', properties: {'email': email});
  }

  Future signInAnonymously() async {
    await authService.signInAnonymously();
    debugPrint("Signed in with temporary account: ${authService.uid}");

    MixpanelService.mixpanel?.identify(authService.uid!);
    MixpanelService.mixpanel?.track('Signup Anonymously');
  }

  Future logout() async {
    await authService.logout();
    MixpanelService.mixpanel?.track('Logout');
    MixpanelService.mixpanel?.reset();
  }
}
