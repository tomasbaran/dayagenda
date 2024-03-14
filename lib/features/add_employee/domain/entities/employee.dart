import 'package:dayagenda/features/add_employee/domain/entities/employee_status.dart';
import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  String? uid;
  String nickname;
  String? firstName;
  String? secondName;
  String? thirdName;
  String? email;
  String? phone;
  EmployeeStatus status;

  Employee({
    required this.nickname,
    this.firstName,
    this.status = EmployeeStatus.invitationSent,
    this.uid,
    this.secondName,
    this.thirdName,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [nickname, uid, firstName, secondName, thirdName, email, phone, status];

  @override
  bool get stringify => true;
}
