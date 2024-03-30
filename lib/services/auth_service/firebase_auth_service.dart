import 'dart:async';

import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis/tasks/v1.dart';
import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/services/analytics_service.dart';

class FirebaseAuthService extends AuthService {
  final AppState appState = locate<AppState>();
  // creating firebase instance
  @override
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  String? get uid => auth.currentUser?.uid;

  @override
  StreamSubscription<User?> myAuthSubscription() => auth.userChanges().listen((User? user) {
        // print('firing event: ${user?.refreshToken}');
      });

  // GoogleSignIn googleSignIn = GoogleSignIn(
  //   scopes: <String>[CalendarApi.calendarScope, TasksApi.tasksScope],
  // );

  @override
  Future<UserCredential?> signInAnonymously() async {
    try {
      final result = await auth.signInAnonymously();
      appState.updateAgenda(auth.currentUser!.uid);
      AnalyticsService().writeSignupDate();
      return result;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          debugPrint("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          debugPrint("Unknown error.");
      }
      return null;
    }
  }

  @override
  Future<UserCredential?> signupWithEmailAndPassword(String emailAddress, String password) async {
    try {
      final result = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailAddress, password: password);
      appState.updateAgenda(auth.currentUser!.uid);

      return result;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          throw "You already have an account with this email address. Please, log in instead.";
        case "provider-already-linked":
          throw "The provider has already been linked to the user.";
        case "invalid-credential":
          throw "The provider's credential is not valid.";
        case "credential-already-in-use":
          debugPrint("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          break;
        // See the API reference for the full list of error codes.
        default:
          throw e.code;
      }
    }
  }

  @override
  Future signupByConvertingAnonymousUserToPermanentUser(String emailAddress, String password) async {
    // Email and password sign-in
    final credential = EmailAuthProvider.credential(email: emailAddress, password: password);
    appState.updateAgenda(auth.currentUser!.uid);

    try {
      if (auth.currentUser == null) {
        throw "Please kill the app and try again.";
      } else {
        await FirebaseAuth.instance.currentUser?.linkWithCredential(credential);
        // await auth.currentUser?.linkWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "email-already-in-use":
          throw "You already have an account with this email address. Please, log in instead.";
        case "provider-already-linked":
          throw "The provider has already been linked to the user.";
        case "invalid-credential":
          throw "The provider's credential is not valid.";
        case "credential-already-in-use":
          debugPrint("The account corresponding to the credential already exists, "
              "or is already linked to a Firebase User.");
          break;
        // See the API reference for the full list of error codes.
        default:
          throw e.code;
      }
    }
  }

  @override
  Future loginWithEmailAndPassword(String emailAddress, String password) async {
    try {
      await auth.signInWithEmailAndPassword(email: emailAddress, password: password);
      appState.updateAgenda(auth.currentUser!.uid);

      print('firebase_auth_service.dart:loginWithEmailAndPassword: User logged in: $emailAddress');
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "invalid-email":
          throw "Your email address appears to be malformed.";
        case "wrong-password":
          throw "Your password is wrong.";
        case "user-not-found":
          throw "User with this email doesn't exist.";
        case "user-disabled":
          throw "User with this email has been disabled.";
        case "too-many-requests":
          throw "Too many requests. Try again later.";
        case "operation-not-allowed":
          throw "Signing in with Email and Password is not enabled.";
        default:
          throw "An undefined Error happened.";
      }
    }
  }

  // function to implement the google signin
  // @override
  // Future<UserCredential> signInWithGoogle() async {
  //   // GoogleSignInAccount? googleUser = await googleSignIn.signIn();

  //   // Obtain the auth details from the request
  //   // final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

  //   // Create a new credential
  //   // final AuthCredential credential = GoogleAuthProvider.credential(
  //   //   idToken: googleAuth?.idToken,
  //   //   accessToken: googleAuth?.accessToken,
  //   // );

  //   //OPTIONAL: Getting users credential
  //   // UserCredential result = await auth.signInWithCredential(credential);
  //   // User? user = result.user;
  //   // print(user);

  //   // return await FirebaseAuth.instance.signInWithCredential(credential);
  // }

  @override
  Future logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
