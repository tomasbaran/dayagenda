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
  final _newGroupTextController = TextEditingController();
  final _manager = locate<GroupTabManager>();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _newGroupTextController.dispose();
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
              Text(employee.nickname, style: navBarAccountEmailInputTextStyle.copyWith(color: groupColors[widget.id])),
              employee.status == EmployeeStatus.registeredAnonymously
                  ? IconButton(onPressed: () => _manager.inviteEmployee(employee), icon: const Icon(Icons.send, color: kBlueAccentColor, size: 18))
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
                      controller: _newGroupTextController,
                      validator: (value) => (value == null || value.isEmpty) ? 'Por favor, ingrese un nombre' : null,
                      style: navBarAccountEmailInputTextStyle,
                      decoration: InputDecoration(
                        hintText: 'Apodo del empleado',
                        hintStyle: navBarAccountEmailInputTextStyle.copyWith(color: kBlueAccentColor),
                        prefixIcon: const Icon(
                          Icons.person_add_alt_outlined,
                          color: kBlueAccentColor,
                        ),
                        enabledBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            color: kBlueAccentColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(
                            // color: kBlueAccentColor,
                            color: Colors.white,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        final employee = Employee(nickname: _newGroupTextController.text);
                        if (_formKey.currentState!.validate()) {
                          _manager.addEmployeesToDb(employee: employee, group: widget.group);
                        }
                        setState(() {
                          _isAddingEmployee = false;
                          _newGroupTextController.text = '';
                        });
                      },
                      child: Text('Agrega Empleado', style: navBarAccountButtonTitleTextStyle),
                    )
                  ],
                ),
              ),
            ],
          )
      ],
    );
  }
}
