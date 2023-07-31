import 'package:get_it/get_it.dart';
import 'package:today/services/auth_service/auth_service.dart';
import 'package:today/services/auth_service/firebase_auth_service.dart';
import 'package:today/states/app_state.dart';
import 'package:today/states/date_state.dart';
import 'package:today/states/list_state/list_state.dart';
import 'package:today/states/task_state.dart';
import 'package:today/services/list_service/list_service.dart';
import 'package:today/services/list_service/firestore_list_service.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerLazySingleton<ListState>(() => ListState());
  getIt.registerLazySingleton<TaskState>(() => TaskState());
  getIt.registerLazySingleton<AppState>(() => AppState());
  getIt.registerLazySingleton<DateState>(() => DateState());
  getIt.registerLazySingleton<ListService>(() => FirestoreListService());
  getIt.registerLazySingleton<AuthService>(() => FirebaseAuthService());
}
