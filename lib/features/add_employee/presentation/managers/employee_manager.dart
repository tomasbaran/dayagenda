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
    await _firestoreRepository.updateEmployee(
      tmpEmployeeId,
      employeeUid,
      email,
      firstName,
    );
  }
}
