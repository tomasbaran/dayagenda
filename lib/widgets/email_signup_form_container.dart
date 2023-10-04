import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:today/models/enums.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/states/app_state.dart';
import 'package:today/states/auth_state.dart';
import 'package:today/style/style_constants.dart';
import 'package:today/utils/screen_utlis.dart';

class EmailFormContainer extends StatefulWidget {
  const EmailFormContainer.signup({super.key}) : isRegisterType = true;
  const EmailFormContainer.login({super.key}) : isRegisterType = false;

  final isRegisterType;

  @override
  State<EmailFormContainer> createState() => _EmailFormContainerState();
}

class _EmailFormContainerState extends State<EmailFormContainer> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final authState = getIt<AuthState>();
  final appState = getIt<AppState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: kThemeColor12,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextFormField(
              autofocus: true,
              style: navBarAccountEmailInputTextStyle,
              controller: _emailController,
              decoration: InputDecoration(
                // enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                icon: Icon(Icons.email, color: kThemeColor2),
                labelText: 'Email',
                labelStyle: navBarAccountEmailInputLabelTextStyle,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                return null;
              },
            ),
            TextFormField(
              style: navBarAccountEmailInputTextStyle,
              controller: _passwordController,
              decoration: InputDecoration(
                icon: Icon(Icons.lock, color: kThemeColor2),
                labelText: 'Password',
                labelStyle: navBarAccountEmailInputLabelTextStyle,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
              obscureText: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Center(
                child: ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Capture a reference to the ScaffoldMessengerState before async call
                      final scaffoldMessengerState = ScaffoldMessenger.of(context);
                      try {
                        widget.isRegisterType
                            ? await authState.signupByConvertingAnonymousUserToPermanentUser(_emailController.text, _passwordController.text)
                            : await authState.loginWithEmailAndPassword(_emailController.text, _passwordController.text);
                        ScreenUtils.showMySnackBar(
                          scaffoldMessengerState: scaffoldMessengerState,
                          snackBarType: SnackBarType.success,
                          title: 'Signup Success!',
                          message: widget.isRegisterType
                              ? 'You signed up successfully with ${_emailController.text}'
                              : 'You logged in successfully with ${_emailController.text}',
                        );
                      } catch (e) {
                        ScreenUtils.showMySnackBar(
                          scaffoldMessengerState: scaffoldMessengerState,
                          snackBarType: SnackBarType.error,
                          title: widget.isRegisterType ? 'Signup Error [${_emailController.text}]' : 'Login Error [${_emailController.text}]',
                          message: e.toString(),
                        );

                        log('Signup Error #7: $e Data: ${_emailController.text}, ${_passwordController.text}');
                      }
                      appState.navigatorKey.currentState?.pop();
                    }
                  },
                  child: Text(
                    widget.isRegisterType ? 'Sign Up' : 'Log In',
                    style: navBarAccountEmailSubmitButtonTextStyle,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
