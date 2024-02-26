import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthImpl {
  FirebaseAuth auth;
  FirebaseAuthImpl({required this.auth});

  registerEmployeeAnonymously() => auth.signInAnonymously();
}
