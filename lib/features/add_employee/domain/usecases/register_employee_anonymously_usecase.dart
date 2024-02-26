import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterEmployeesAnonymouslyUsecase {
  final AuthService repository;

  RegisterEmployeesAnonymouslyUsecase(this.repository);

  Future<UserCredential> call() async {
    return await repository.signInAnonymously();
  }
}
