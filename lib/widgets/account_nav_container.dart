import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:today/services/auth_service/auth_service.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';
import 'package:today/utils/send_feedback.dart';

class AccountNavContainer extends StatelessWidget {
  AccountNavContainer({super.key});

  final authService = getIt<AuthService>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // shrinkWrap: true,
        mainAxisSize: MainAxisSize.min,
        children: [
          Visibility(
            visible: authService.isSignedUp,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'signed in as ${authService.auth.currentUser?.email}',
                style: navBarAccountInformationTextStyle,
              ),
            ),
          ),
          Visibility(
            visible: !authService.isSignedUp,
            child: SignInButton(Buttons.GoogleDark, text: 'Sync Google Calendar', onPressed: () async {
              await authService.signInWithGoogle();
              // if (authService.uid != null) {
              //   if (context.mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TasksScreen()));
              // } else {
              //   throw 'Error #5: unable to signInWithGoogle';
              // }
            }),
          ),
          Visibility(
            visible: authService.isSignedUp,
            child: GestureDetector(
              onTap: () => authService.logout(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Log Out',
                  style: navBarAccountTextStyle,
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () => SendFeedback().sendEmail(context, 'Feedback'),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: navBarAccountInformationTextStyle.color,
                  borderRadius: const BorderRadius.all(Radius.circular(6)),
                ),
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      FontAwesomeIcons.commentAlt,
                      color: navBarAccountHighlightedTextStyle.color,
                      size: 20,
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Send Feedback',
                      style: navBarAccountHighlightedTextStyle,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
