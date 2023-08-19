import 'package:flutter/material.dart';
import 'package:today/style/style_constants.dart';

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
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Processing Data')),
                      );
                      // You can call your registration API here, using the values from _emailController.text and _passwordController.text
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
