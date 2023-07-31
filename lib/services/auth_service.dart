import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart';
import 'package:googleapis/tasks/v1.dart';

class AuthService {
  // creating firebase instance
  final FirebaseAuth auth = FirebaseAuth.instance;
  String? get uid => auth.currentUser?.uid;

  GoogleSignIn googleSignIn = GoogleSignIn(
    scopes: <String>[CalendarApi.calendarScope, TasksApi.tasksScope],
  );

  // function to implement the google signin
  Future<UserCredential> signInWithGoogle(BuildContext context) async {
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

  logout() {
    FirebaseAuth.instance.signOut();
  }
}
