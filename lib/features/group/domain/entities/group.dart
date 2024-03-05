import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:equatable/equatable.dart';

class Group extends Equatable {
  final String? id;
  final String name;
  final String ownerUid;
  List<Employee> employees;

  Group({
    this.id,
    required this.ownerUid,
    required this.name,
    this.employees = const [], // Make it nullable in the constructor
  }); // Default value using initializer list

  @override
  List<Object?> get props => [id, name, ownerUid, employees];

  @override
  bool get stringify => true;
}
