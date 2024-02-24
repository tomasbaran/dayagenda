import 'package:flutter/material.dart';

class RegisterEmployeeScreen extends StatelessWidget {
  final String uid;
  const RegisterEmployeeScreen({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('Register Employee Screen: $uid'));
  }
}
