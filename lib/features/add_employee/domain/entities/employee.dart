import 'package:dayagenda/features/add_employee/domain/entities/employee_status.dart';
import 'package:equatable/equatable.dart';

class Employee extends Equatable {
  String? uid;
  String? tmpId;
  String? nickname;
  String? firstName;
  String? secondName;
  String? thirdName;
  String? email;
  String? phone;
  EmployeeStatus status;

  Employee({
    this.nickname,
    this.firstName,
    this.status = EmployeeStatus.addedByOwner,
    this.uid,
    this.tmpId,
    this.secondName,
    this.thirdName,
    this.email,
    this.phone,
  });

  @override
  List<Object?> get props => [
        tmpId,
        nickname,
        uid,
        firstName,
        secondName,
        thirdName,
        email,
        phone,
        status,
      ];

  @override
  bool get stringify => true;

  // Add the copyWith method
  Employee copyWith({
    String? uid,
    String? tmpId,
    String? nickname,
    String? firstName,
    String? secondName,
    String? thirdName,
    String? email,
    String? phone,
    EmployeeStatus? status,
  }) {
    return Employee(
      uid: uid ?? this.uid,
      tmpId: tmpId ?? this.tmpId,
      nickname: nickname ?? this.nickname,
      firstName: firstName ?? this.firstName,
      secondName: secondName ?? this.secondName,
      thirdName: thirdName ?? this.thirdName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      status: status ?? this.status,
    );
  }
}
