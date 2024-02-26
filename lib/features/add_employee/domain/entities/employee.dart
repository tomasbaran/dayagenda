import 'package:dayagenda/features/add_employee/domain/entities/employee_status.dart';

class Employee {
  final String? uid;
  final String firstName;
  final String? secondName;
  final String? thirdName;
  final String? email;
  final String phone;
  EmployeeStatus status;

  Employee({
    this.status = EmployeeStatus.invitationSent,
    this.uid,
    required this.firstName,
    this.secondName,
    this.thirdName,
    this.email,
    required this.phone,
  });
}
