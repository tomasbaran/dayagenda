import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';
import 'package:dayagenda/features/group/domain/entities/group.dart';

class AddEmployeeToGroupsCollectionUsecase {
  final FirestoreRepository _repository;
  AddEmployeeToGroupsCollectionUsecase(this._repository);

  Future<bool> call(Group group, Employee employee) async {
    return _repository.addEmployeeToGroupsCollection(group, employee);
  }
}
