import 'package:get_it/get_it.dart';
import 'package:today/managers/app_manager.dart';
import 'package:today/managers/list_manager.dart';
import 'package:today/managers/task_manager.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerLazySingleton<ListManager>(() => ListManager());
  getIt.registerLazySingleton<TaskManager>(() => TaskManager());
  getIt.registerLazySingleton<AppManager>(() => AppManager());
}
