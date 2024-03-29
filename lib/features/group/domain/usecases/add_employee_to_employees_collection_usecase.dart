import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';

class AddTmpEmployeeInfo {
  final FirestoreRepository _repository;
  AddTmpEmployeeInfo(this._repository);

  Future<bool> call(Employee employee) async => await _repository.addTmpEmployeeInfo(employee);
}
