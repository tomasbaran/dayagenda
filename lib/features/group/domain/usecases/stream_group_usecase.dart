import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/features/add_employee/domain/entities/employee_status.dart';
import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';
import 'package:dayagenda/features/group/domain/entities/group.dart';

class StreamGroupUseCase {
  final FirestoreRepository _repository;
  StreamGroupUseCase(this._repository);
  late StreamController<Group> controller;

  Stream<Group> call(DocumentReference groupRef) {
    // Create a StreamController to create and control the stream
    controller = StreamController<Group>();
    final subs = _repository.subscribeToGroupData(groupRef);
    subs.onData((data) {
      List<Employee> parsedEmployees = [];

      final group = data.data() as Map<String, dynamic>;
      print('StreamGroupUseCase.group: $group\n');
      print('StreamGroupUseCase.employees: ${group['employees']}\n');

      if (group['employees'] != null) {
        List employees = group['employees'];
        for (var employee in employees) {
          print('new employee: $employee;\n');

          EmployeeStatus? employeeStatus;
          switch (employee['status']) {
            case 'invitationSent':
              employeeStatus = EmployeeStatus.invitationSent;
              break;
            case 'registered':
              employeeStatus = EmployeeStatus.registered;
              break;
            default:
              employeeStatus = EmployeeStatus.registeredAnonymously;
              break;
          }

          Employee parsedEmployee = Employee(
            nickname: employee['nickname'],
            uid: employee['uid'],
            phone: employee['phone'],
            status: employeeStatus,
          );
          print('parsedEmployee: $parsedEmployee\n');
          parsedEmployees.add(parsedEmployee);
        }
      }

      final Group parsedGroup = Group(
        id: groupRef.id,
        ownerUid: group['owner_uid'],
        name: group['name'],
        employees: parsedEmployees,
      );
      print('StreamGroupUseCase.parsedGroup: $parsedGroup\n');

      controller.add(parsedGroup);
    });

    // Return the stream from the controller
    return controller.stream;
  }

  dispose() {
    controller.close();
  }
}
