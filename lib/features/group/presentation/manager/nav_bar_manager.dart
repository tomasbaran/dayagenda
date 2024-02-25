import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/features/group/domain/entities/owner.dart';
import 'package:dayagenda/features/group/domain/usecases/create_owner_in_db.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/states/app_state.dart';

class NavBarManager {
  final CreateOwnerInDbUsecase createOwnerInDb;
  NavBarManager({required this.createOwnerInDb});

  Future tapGroupIcon() async {
    final appState = locate<AppState>();
    final authService = locate<AuthService>();
    if (authService.auth.currentUser == null) {
      appState.updateNavBarSelection(NavBarSelection.account);
    } else {
      final currentUser = authService.auth.currentUser;
      final owner = Owner(uid: currentUser!.uid, email: currentUser.email);
      await createOwnerInDb(owner);
    }
    return;
  }
}
