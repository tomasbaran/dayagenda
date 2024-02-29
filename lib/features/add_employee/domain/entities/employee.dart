import 'package:dayagenda/features/add_employee/domain/entities/employee_status.dart';
import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  String? uid;
  String firstName;
  String? secondName;
  String? thirdName;
  String? email;
  String phone;
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

  @override
  List<Object?> get props => [uid, firstName, secondName, thirdName, email, phone, status];

  @override
  bool get stringify => true;
}
