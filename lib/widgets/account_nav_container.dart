import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:today/services/auth_service/auth_service.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/states/app_state.dart';
import 'package:today/style/style_constants.dart';
import 'package:today/utils/send_feedback.dart';
import 'package:today/widgets/email_signup_form_container.dart';

class AccountNavContainer extends StatelessWidget {
  AccountNavContainer({super.key});

  final authService = getIt<AuthService>();
  final appState = getIt<AppState>();

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
          ValueListenableBuilder(
              valueListenable: appState.isSignedIn,
              builder: (context, isSignedIn, _) {
                return Visibility(
                  visible: isSignedIn,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'signed in as ${authService.auth.currentUser?.email}',
                      style: navBarAccountEmailInputTextStyle,
                    ),
                  ),
                );
              }),
          ValueListenableBuilder(
              valueListenable: appState.isSignedIn,
              builder: (context, isSignedIn, _) {
                return Visibility(
                  visible: !isSignedIn,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                        onPressed: () => showModalBottomSheet(
                          isScrollControlled: true,
                          useSafeArea: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(42),
                              topRight: Radius.circular(42),
                            ),
                          ),
                          context: context,
                          builder: (BuildContext context) => EmailFormContainer.signup(),
                        ),
                        child: Text('Sign Up', style: navBarAccountButtonTitleTextStyle),
                      ),
                      ElevatedButton(
                        onPressed: () => showModalBottomSheet(
                          isScrollControlled: true,
                          useSafeArea: true,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(42),
                              topRight: Radius.circular(42),
                            ),
                          ),
                          context: context,
                          builder: (BuildContext context) => EmailFormContainer.login(),
                        ),
                        child: Text('Log In', style: navBarAccountButtonTitleTextStyle),
                      ),
                    ],
                  ),
                );
              }),

          ValueListenableBuilder(
              valueListenable: appState.isSignedIn,
              builder: (context, isSignedIn, _) {
                return Visibility(
                  visible: isSignedIn,
                  child: GestureDetector(
                    onTap: () => authService.logout(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Log Out',
                        style: navBarAccountTextStyle.copyWith(color: Colors.red),
                      ),
                    ),
                  ),
                );
              }),
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
