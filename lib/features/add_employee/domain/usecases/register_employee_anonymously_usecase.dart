import 'package:dayagenda/services/auth_service/firebase_auth_service.dart';

class RegisterEmployeeAnonymouslyUsecase {
  final FirebaseAuthService repository;

  RegisterEmployeeAnonymouslyUsecase(this.repository);

  Future call() async => await repository.signInAnonymously();
}
