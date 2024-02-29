import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';

class AddEmployeeToGroupsCollectionUsecase {
  final FirestoreRepository _repository;
  AddEmployeeToGroupsCollectionUsecase(this._repository);

  Future<void> call(Employee employee) async {
    return _repository.addEmployeeToGroupsCollection(employee);
  }
}
