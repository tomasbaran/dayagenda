import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';

class EmployeeManager {
  final FirestoreRepository _firestoreRepository;
  EmployeeManager(this._firestoreRepository);

  Future finalEmployeeRegistration(String employeeUid, String firstName) async {
    final Map<String, dynamic> employeeData = {
      'first_name': firstName,
      'employee_status': 'registered',
    };
    await _firestoreRepository.updateEmployee(employeeUid, employeeData);
  }
}
