import 'package:dayagenda/services/auth_service/firebase_auth_service.dart';

class RegisterEmployeeAnonymously {
  final FirebaseAuthService repository;

  RegisterEmployeeAnonymously(this.repository);

  Future call() async => await repository.signInAnonymously();
}
