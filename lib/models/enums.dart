import 'package:today/globals/constants.dart';

enum NavBarSelection {
  unselected,
  calendar,
  list,
  account,
}

enum DayType {
  isToday,
  isTomorrow,
  isYesterday,
  isNoSpecial,
}

enum SheetType {
  newTask,
  updateTask,
}

enum SnackBarType {
  success,
  error,
}

enum FlavorType {
  dev(baseUrlDev),
  live(baseUrlLive);

  const FlavorType(this.baseUrl);
  final String baseUrl;
}
