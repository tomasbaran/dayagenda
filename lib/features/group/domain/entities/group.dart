import 'package:dayagenda/features/group/domain/entities/employee.dart';
import 'package:googleapis/driveactivity/v2.dart';

class Group {
  final String id;
  final String name;
  final Owner ownerUid;
  List<Employee> employeeUids = [];

  Group({
    required this.ownerUid,
    required this.id,
    required this.name,
  });
}
