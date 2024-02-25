import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';
import 'package:dayagenda/features/group/domain/usecases/create_group_in_db_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/create_owner_in_db_usecase.dart';
import 'package:dayagenda/features/group/presentation/manager/nav_bar_manager.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Register FirebaseFirestore instance
  locate.registerLazySingleton<FirebaseFirestore>(() => FirebaseFirestore.instance);
  locate.registerLazySingleton<FirebaseAuth>(() => FirebaseAuthService().auth);

  // feature: Group
  // Repositories
  locate.registerLazySingleton<FirestoreRepository>(() => FirestoreRepository(db: locate<FirebaseFirestore>()));
  // Use cases
  locate.registerLazySingleton<CreateOwnerInDbUsecase>(() => CreateOwnerInDbUsecase(repository: locate<FirestoreRepository>()));
  locate.registerLazySingleton<CreateGroupInDbUsecase>(() => CreateGroupInDbUsecase(repository: locate<FirestoreRepository>()));
  // Managers
  locate.registerLazySingleton<NavBarManager>(
      () => NavBarManager(createOwnerInDb: locate<CreateOwnerInDbUsecase>(), createGroupInDb: locate<CreateGroupInDbUsecase>()));
}
