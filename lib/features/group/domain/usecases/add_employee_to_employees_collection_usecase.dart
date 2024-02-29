import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';

class AddEmployeeToEmployeesCollectionUsecase {
  final FirestoreRepository _repository;
  AddEmployeeToEmployeesCollectionUsecase(this._repository);

  Future<bool> call(Employee employee) async {
    return _repository.addEmployeeToEmployeesCollection(employee);
  }
}
