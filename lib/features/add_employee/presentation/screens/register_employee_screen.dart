import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/features/add_employee/presentation/managers/employee_manager.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/states/auth_state.dart';
import 'package:dayagenda/style/style_constants.dart';
import 'package:dayagenda/utils/screen_utlis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterEmployeeScreen extends StatefulWidget {
  final String tmpEmployeeId;
  RegisterEmployeeScreen({
    super.key,
    required this.tmpEmployeeId,
  });

  @override
  State<RegisterEmployeeScreen> createState() => _RegisterEmployeeScreenState();
}

class _RegisterEmployeeScreenState extends State<RegisterEmployeeScreen> {
  final _firstNameTextController = TextEditingController();
  final _secondNameTextController = TextEditingController();
  final _thirdNameTextController = TextEditingController();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  final _employeeFormKey = GlobalKey<FormState>();

  final authState = locate<AuthState>();

  final _manager = locate<EmployeeManager>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Termina registración'),
        ),
        body: Container(
          color: kThemeColor12,
          child: Form(
            key: _employeeFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextFormField(
                  autofocus: true,
                  controller: _firstNameTextController,
                  validator: (value) => (value == null || value.isEmpty) ? 'Por favor, ingrese un nombre' : null,
                  style: navBarAccountEmailInputTextStyle,
                  decoration: InputDecoration(
                    hintText: 'Nombre',
                    hintStyle: navBarAccountEmailInputTextStyle.copyWith(color: kBlueAccentColor),
                    prefixIcon: const Icon(Icons.person, color: kBlueAccentColor),
                    // Update border styles as needed
                  ),
                ),
                TextFormField(
                  controller: _secondNameTextController,
                  validator: (value) => (value == null || value.isEmpty) ? 'Por favor, ingrese su primer apellido' : null,
                  style: navBarAccountEmailInputTextStyle,
                  decoration: InputDecoration(
                    hintText: 'Primer Apellido',
                    hintStyle: navBarAccountEmailInputTextStyle.copyWith(color: kBlueAccentColor),
                    prefixIcon: const Icon(Icons.person, color: kBlueAccentColor),
                    // Update border styles as needed
                  ),
                ),
                TextFormField(
                  controller: _thirdNameTextController,
                  style: navBarAccountEmailInputTextStyle,
                  decoration: InputDecoration(
                    hintText: 'Segundo Apellido',
                    hintStyle: navBarAccountEmailInputTextStyle.copyWith(color: kBlueAccentColor),
                    prefixIcon: const Icon(Icons.person, color: kBlueAccentColor),
                    // Update border styles as needed
                  ),
                ),
                TextFormField(
                  style: navBarAccountEmailInputTextStyle,
                  controller: _emailController,
                  decoration: InputDecoration(
                    // enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
                    icon: const Icon(Icons.email, color: kThemeColor2),
                    labelText: 'Email',
                    labelStyle: navBarAccountEmailInputLabelTextStyle,
                  ),
                ),
                TextFormField(
                  style: navBarAccountEmailInputTextStyle,
                  controller: _passwordController,
                  decoration: InputDecoration(
                    icon: const Icon(Icons.lock, color: kThemeColor2),
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
                ElevatedButton(
                  onPressed: () async {
                    if (_employeeFormKey.currentState!.validate()) {
                      final scaffoldMessengerState = ScaffoldMessenger.of(context);
                      try {
                        final userCredential = await authState.signupWithEmailAndPassword(_emailController.text, _passwordController.text);
                        print('signup success!');
                        await _manager.addEmployeeInfo(
                          widget.tmpEmployeeId,
                          userCredential?.user?.uid ?? 'errorUid',
                          _emailController.text,
                          _firstNameTextController.text,
                          _secondNameTextController.text,
                          _thirdNameTextController.text == '' ? null : _thirdNameTextController.text,
                        );

                        // Check if the widget is still mounted before trying to use the context
                        if (!mounted) return;
                        context.go('/dev');
                      } catch (e) {
                        print('register error: $e');
                        ScreenUtils.showMySnackBar(
                          scaffoldMessengerState: scaffoldMessengerState,
                          snackBarType: SnackBarType.error,
                          title: 'Register Error [${_emailController.text}]',
                          message: e.toString(),
                        );
                      }
                    }
                  },
                  child: Text('Siguiente', style: navBarAccountButtonTitleTextStyle),
                ),
              ],
            ),
          ),
        ));
  }
}
