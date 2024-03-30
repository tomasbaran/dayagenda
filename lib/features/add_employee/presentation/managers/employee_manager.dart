import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';

class EmployeeManager {
  final FirestoreRepository _firestoreRepository;
  EmployeeManager(this._firestoreRepository);

  Future addEmployeeInfo(
    String tmpEmployeeId,
    String employeeUid,
    String email,
    String firstName,
  ) async {
    final Employee employee = Employee(
      tmpId: tmpEmployeeId,
      uid: employeeUid,
      email: email,
      firstName: firstName,
    );

    await _firestoreRepository.migrateTmpEmployeeToEmployee(employee);
  }
}
