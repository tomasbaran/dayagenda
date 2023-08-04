import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:today/services/auth_service/auth_service.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';
import 'package:today/utils/send_feedback.dart';
import 'package:today/widgets/email_signup_form_container.dart';

class AccountNavContainer extends StatelessWidget {
  AccountNavContainer({super.key});

  final authService = getIt<AuthService>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // shrinkWrap: true,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'My Account',
            style: navBarHeadlineTextStyle,
          ),
          const SizedBox(height: 24),
          Visibility(
            visible: authService.isSignedUp,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'signed in as ${authService.auth.currentUser?.email}',
                style: navBarAccountEmailInputTextStyle,
              ),
            ),
          ),
          EmailSignupFormContainer(),
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
          // const SizedBox(height: 8),
        ],
      ),
    );
  }
}
