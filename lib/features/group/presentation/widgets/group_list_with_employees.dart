import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/features/add_employee/domain/entities/employee_status.dart';
import 'package:dayagenda/features/group/domain/entities/group.dart';
import 'package:dayagenda/features/group/presentation/manager/group_tab_manager.dart';
import 'package:dayagenda/style/style_constants.dart';
import 'package:flutter/material.dart';

class GroupListWithEmployees extends StatefulWidget {
  const GroupListWithEmployees({
    super.key,
    required this.group,
    required this.id,
  });
  final int id;
  final Group group;

  @override
  State<GroupListWithEmployees> createState() => _GroupListWithEmployeesState();
}

class _GroupListWithEmployeesState extends State<GroupListWithEmployees> {
  bool _isAddingEmployee = false;
  final _phoneTextController = TextEditingController();
  final _nicknameTextController = TextEditingController();
  final _phoneNumberController = TextEditingController(); // Controller for the phone number
  final _manager = locate<GroupTabManager>();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneTextController.dispose();
    _nicknameTextController.dispose();
    _phoneNumberController.dispose(); // Dispose the phone number controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(
              height: 48,
              width: 48,
            ),
            Expanded(
              child: Text(
                widget.group.name.toUpperCase(),
                style: navBarAccountHighlightedTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: InkWell(
                onTap: () => setState(() => _isAddingEmployee = !_isAddingEmployee),
                child: CircleAvatar(
                  radius: 12,
                  child: Icon(
                    Icons.person_add_alt_outlined,
                    size: 18,
                    color: groupColors[widget.id],
                  ),
                ),
              ),
            ),
          ],
        ),
        for (var employee in widget.group.employees)
          Row(
            children: [
              Text(employee.status.name.toString(), style: navBarAccountEmailInputTextStyle.copyWith(color: groupColors[widget.id])),
              employee.status == EmployeeStatus.registeredAnonymously
                  ? IconButton(
                      onPressed: () => _manager.inviteEmployee(employee, widget.group),
                      icon: const Icon(Icons.send, color: kBlueAccentColor, size: 18))
                  : Icon(Icons.check, color: kBlueAccentColor, size: 18),
            ],
          ),
        const SizedBox(height: 24),
        if (_isAddingEmployee)
          Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nicknameTextController,
                      validator: (value) => (value == null || value.isEmpty) ? 'Por favor, ingrese un nombre' : null,
                      style: navBarAccountEmailInputTextStyle,
                      decoration: InputDecoration(
                        hintText: 'Apodo del empleado',
                        hintStyle: navBarAccountEmailInputTextStyle.copyWith(color: kBlueAccentColor),
                        prefixIcon: const Icon(Icons.person, color: kBlueAccentColor),
                        // Update border styles as needed
                      ),
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      controller: _phoneNumberController,
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a phone number' : null,
                      style: navBarAccountEmailInputTextStyle,
                      decoration: InputDecoration(
                        hintText: 'Phone number',
                        hintStyle: navBarAccountEmailInputTextStyle.copyWith(color: kBlueAccentColor),
                        prefixIcon: const Icon(Icons.phone, color: kBlueAccentColor),
                        // Update border styles as needed
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final employee = Employee(
                            nickname: _nicknameTextController.text,
                            phone: _phoneNumberController.text,
                            // Include additional fields as required
                          );
                          _manager.addEmployeesToDb(employee: employee, group: widget.group);
                          setState(() {
                            _isAddingEmployee = false;
                            _nicknameTextController.clear();
                            _phoneNumberController.clear();
                          });
                        }
                      },
                      child: Text('Agrega Empleado', style: navBarAccountButtonTitleTextStyle),
                    )
                  ],
                ),
              ),
            ],
          ),
      ],
    );
  }
}
