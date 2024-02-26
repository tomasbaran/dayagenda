import 'package:dayagenda/features/add_employee/data/repositories/firebase_auth.dart';

class RegisterEmployeeAnonymously {
  final FirebaseAuthImpl repository;

  RegisterEmployeeAnonymously(this.repository);

  Future call() async => await repository.registerEmployeeAnonymously();
}
