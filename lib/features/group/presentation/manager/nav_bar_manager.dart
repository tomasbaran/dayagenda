import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/features/group/domain/entities/owner.dart';
import 'package:dayagenda/features/group/domain/usecases/add_owner_to_db.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/states/app_state.dart';

class NavBarManager {
  final AddOwnerToDbUsecase addOwnerToDb;
  NavBarManager({required this.addOwnerToDb});

  Future tapGroupIcon() async {
    final appState = locate<AppState>();
    final authService = locate<AuthService>();
    if (authService.auth.currentUser == null) {
      appState.updateNavBarSelection(NavBarSelection.account);
    } else {
      final currentUser = authService.auth.currentUser;
      final owner = Owner(uid: currentUser!.uid, email: currentUser.email);
      await addOwnerToDb(owner);
    }
    return;
  }
}
