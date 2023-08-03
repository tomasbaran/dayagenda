import 'package:firebase_auth/firebase_auth.dart';

abstract class AuthService {
  FirebaseAuth get auth;

  String? get uid;

  Future<UserCredential> signInWithGoogle();

  logout();
}
