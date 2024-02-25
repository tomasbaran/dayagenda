import 'package:dayagenda/features/group/domain/entities/employee.dart';
import 'package:googleapis/driveactivity/v2.dart';

class Group {
  final String id;
  final String name;
  final Owner owner;
  List<Employee> employees = [];

  Group({
    required this.owner,
    required this.id,
    required this.name,
  });
}
