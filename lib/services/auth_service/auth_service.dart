import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  FirebaseAuth get auth;

  String? get uid;

  StreamSubscription<User?> myAuthSubscription();

  Future<UserCredential?> signInAnonymously();

  Future signupByConvertingAnonymousUserToPermanentUser(String emailAddress, String password);

  Future signupByConvertingAnonymousEmployeeToPermanentEmployee(String emailAddress, String password);

  Future loginWithEmailAndPassword(String emailAddress, String password);

  // Future<UserCredential> signInWithGoogle();

  Future logout();
}
