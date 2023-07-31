//SignInScreen

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';
import 'tasks_screen.dart';
import '../services/auth_service.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final authService = getIt<AuthService>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue,
              Colors.red,
            ],
          ),
        ),
        child: Card(
          margin: EdgeInsets.only(top: 200, bottom: 200, left: 30, right: 30),
          elevation: 20,
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    const Text(
                      "DayAgenda",
                      style: loginScreenTitle,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Plan your day. Enjoy your night.',
                      // 'Day is calmer when planned.',
                      style: loginScreenSubtitle,
                    ),
                  ],
                ),
                SignInButton(Buttons.GoogleDark, text: 'Sync Google Calendar', onPressed: () async {
                  await authService.signInWithGoogle(context);
                  if (authService.uid != null) {
                    if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => TasksScreen()));
                  } else {
                    throw 'Error #5: unable to signInWithGoogle';
                  }
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
