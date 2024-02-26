import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';

class Group {
  final String? id;
  final String name;
  final String ownerUid;
  List<Employee> employeeUids = [];

  Group({
    required this.ownerUid,
    this.id,
    required this.name,
  });
}
