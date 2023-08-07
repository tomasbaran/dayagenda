import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis/tasks/v1.dart';
import 'package:today/services/auth_service/auth_service.dart';

class FirebaseAuthService extends AuthService {
  // creating firebase instance
  @override
  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  String? get uid => auth.currentUser?.uid;

  @override
  bool get isSignedUp {
    final currentUser = auth.currentUser;
    if (currentUser == null) {
      return false;
    } else {
      if (currentUser.isAnonymous) {
        return false;
      } else {
        return true;
      }
    }
  }

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[CalendarApi.calendarScope, TasksApi.tasksScope],
  );

  @override
  signInAnonymously() async {
    try {
      await auth.signInAnonymously();
      print("Signed in with temporary account.");
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case "operation-not-allowed":
          print("Anonymous auth hasn't been enabled for this project.");
          break;
        default:
          print("Unknown error.");
      }
    }
  }

  // function to implement the google signin
  @override
  Future<UserCredential> signInWithGoogle() async {
    GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

    // Create a new credential
    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleAuth?.idToken,
      accessToken: googleAuth?.accessToken,
    );

    //OPTIONAL: Getting users credential
    // UserCredential result = await auth.signInWithCredential(credential);
    // User? user = result.user;
    // print(user);

    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  @override
  Future logout() async {
    await FirebaseAuth.instance.signOut();
  }
}
