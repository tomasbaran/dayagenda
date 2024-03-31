import 'package:dayagenda/globals/constants.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/states/auth_state.dart';
import 'package:dayagenda/style/style_constants.dart';
import 'package:dayagenda/utils/send_feedback.dart';
import 'package:dayagenda/widgets/email_signup_form_container.dart';

class AccountNavContainer extends StatelessWidget {
  AccountNavContainer({super.key});

  final authService = locate<AuthService>();
  final authState = locate<AuthState>();
  final appState = locate<AppState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: ValueListenableBuilder(
          valueListenable: appState.isSignedIn,
          builder: (context, isSignedIn, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSignedIn ? 'My Account' : 'Account',
                  style: navBarHeadlineTextStyle,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 24),
                  child: Text(
                    isSignedIn ? 'signed in as ${authService.auth.currentUser?.email}' : 'not signed in',
                    style: navBarAccountEmailInputTextStyle,
                  ),
                ),
                if (!isSignedIn)
                  Row(
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
                          builder: (BuildContext context) => const EmailFormContainer.signup(),
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
                          builder: (BuildContext context) => const EmailFormContainer.login(),
                        ),
                        child: Text('Log In', style: navBarAccountButtonTitleTextStyle),
                      ),
                    ],
                  ),
                Visibility(
                  visible: isSignedIn,
                  child: GestureDetector(
                    onTap: () => authState.logout(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Log Out',
                        style: navBarAccountTextStyle.copyWith(color: Colors.red),
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
                if (kDayagendaUrl == baseUrlDev)
                  ElevatedButton(
                    child: Text(
                      'a@a.aa',
                      style: navBarAccountEmailSubmitButtonTextStyle,
                    ),
                    onPressed: () async => await authState.loginWithEmailAndPassword('a@a.aa', '123456'),
                  ),
              ],
            );
          }),
    );
  }
}
