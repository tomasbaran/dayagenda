import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';

class AddTmpEmployeeInfo {
  final FirestoreRepository _repository;
  AddTmpEmployeeInfo(this._repository);

  Future<Employee> call(Employee employee) async => await _repository.updateTmpEmployeeInfo(employee);
}
