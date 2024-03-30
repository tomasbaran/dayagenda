import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/services/firebase_analytics_service.dart';
import 'package:dayagenda/services/mixpanel_service.dart';
import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthState {
  final AuthService authService = locate<AuthService>();
  final AppState appState = locate<AppState>();
  String? lastUsedPassword;
  String? lastUsedEmail;

  Future<UserCredential?> signupWithEmailAndPassword(String email, String password) async =>
      await authService.signupWithEmailAndPassword(email, password);

  Future loginWithEmailAndPassword(String email, String password) async {
    lastUsedPassword = password;
    lastUsedEmail = email;
    await authService.loginWithEmailAndPassword(email, password);
    appState.updateAgenda(authService.uid!);
    debugPrint("Signed in with email: $email [${authService.uid}]");

    FirebaseAnalyticsService.analytics.setUserId(id: authService.uid);
    FirebaseAnalyticsService.analytics.logLogin(loginMethod: 'email');
    FirebaseAnalyticsService.analytics.setUserProperty(name: 'email', value: email);

    MixpanelService.mixpanel?.identify(authService.uid!);
    MixpanelService.mixpanel?.track('Login', properties: {'email': email});
    MixpanelService.mixpanel?.getPeople().set('\$email', email);
  }

  Future signupByConvertingAnonymousUserToPermanentUser(String email, String password) async {
    lastUsedPassword = password;
    lastUsedEmail = email;
    await authService.signupByConvertingAnonymousUserToPermanentUser(email, password);
    appState.updateAgenda(authService.uid!);
    debugPrint("Converted anonymous user with email: $email [${authService.uid}]");

    FirebaseAnalyticsService.analytics.logSignUp(signUpMethod: 'email');
    FirebaseAnalyticsService.analytics.setUserProperty(name: 'email', value: email);

    MixpanelService.mixpanel?.getPeople().set('\$email', email);
    MixpanelService.mixpanel?.track('Signup With Email', properties: {'email': email});
  }

  Future signInAnonymously() async {
    await authService.signInAnonymously();
    appState.updateAgenda(authService.uid!);

    FirebaseAnalyticsService.analytics.setUserId(id: authService.uid);
    FirebaseAnalyticsService.analytics.logLogin(loginMethod: 'anonymous');

    MixpanelService.mixpanel?.identify(authService.uid!);
    MixpanelService.mixpanel?.track('Signup Anonymously');
  }

  Future logout() async {
    await authService.logout();
    FirebaseAnalyticsService.analytics.logEvent(name: 'logout');
    FirebaseAnalyticsService.analytics.resetAnalyticsData();

    MixpanelService.mixpanel?.track('Logout');
    MixpanelService.mixpanel?.reset();
  }
}
