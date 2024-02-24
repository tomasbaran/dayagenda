import 'package:dayagenda/features/group/domain/entities/employee_status.dart';

class Employee {
  final String uid;
  final String firstName;
  final String secondName;
  final String thirdName;
  final String email;
  final String phone;
  EmployeeStatus status;

  Employee({
    this.status = EmployeeStatus.invitationSent,
    required this.uid,
    required this.firstName,
    required this.secondName,
    required this.thirdName,
    required this.email,
    required this.phone,
  });
}
