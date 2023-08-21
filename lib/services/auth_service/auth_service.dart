import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  FirebaseAuth get auth;

  String? get uid;

  bool get isSignedUp;

  Future signInAnonymously();
  Future convertAnonymousUserToPermanentUser(String emailAddress, String password);

  // Future<UserCredential> signInWithGoogle();

  Future logout();
}
