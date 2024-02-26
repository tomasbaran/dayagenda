import 'package:flutter/material.dart';

class AddEmployees extends StatelessWidget {
  const AddEmployees({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Employees'),
      ),
      body: Center(
        child: Text('Add Employees'),
      ),
    );
  }
}
