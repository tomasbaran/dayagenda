import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/services/auth_service/firebase_auth_service.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/states/auth_state.dart';
import 'package:dayagenda/states/date_state.dart';
import 'package:dayagenda/states/list_state/list_state.dart';
import 'package:dayagenda/states/task_state.dart';
import 'package:dayagenda/services/list_service/list_service.dart';
import 'package:dayagenda/services/list_service/firestore_list_service.dart';

final locate = GetIt.instance;

void setupGetIt() {
  locate.registerLazySingleton<ListState>(() => ListState());
  locate.registerLazySingleton<TaskState>(() => TaskState());
  locate.registerLazySingleton<AppState>(() => AppState());
  locate.registerLazySingleton<DateState>(() => DateState());
  locate.registerLazySingleton<ListService>(() => FirestoreListService());
  locate.registerLazySingleton<AuthService>(() => FirebaseAuthService());
  locate.registerLazySingleton<AuthState>(() => AuthState());

  // feature: Group
  // Repositories
  locate.registerLazySingleton<FirestoreRepository>(() => FirestoreRepository(db: ));
  // Use cases
}
