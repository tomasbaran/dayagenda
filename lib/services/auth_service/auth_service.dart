import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

abstract class AuthService {
  FirebaseAuth get auth;

  String? get uid;

  Future<UserCredential> signInWithGoogle(BuildContext context);

  logout();
}
