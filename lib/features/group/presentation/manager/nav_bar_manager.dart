import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/features/add_employee/domain/usecases/register_employee_anonymously_usecase.dart';
import 'package:dayagenda/features/group/domain/entities/group.dart';
import 'package:dayagenda/features/group/domain/entities/owner.dart';
import 'package:dayagenda/features/group/domain/usecases/add_group_id_to_owner_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/create_group_in_db_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/create_owner_in_db_usecase.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/states/app_state.dart';

class NavBarManager {
  final CreateOwnerInDbUsecase createOwnerInDb;
  final CreateGroupInDbUsecase createGroupInDb;
  final UpdateOwnerUsecase updateOwner;
  final RegisterEmployeesAnonymouslyUsecase registerEmployeeAnonymously;
  NavBarManager({required this.createOwnerInDb, required this.createGroupInDb, required this.updateOwner, required this.registerEmployeeAnonymously});
  final appState = locate<AppState>();
  final authService = locate<AuthService>();

  Future tapGroupIcon() async {
    if (authService.auth.currentUser == null) {
      appState.updateNavBarSelection(NavBarSelection.account);
    } else {
      final currentUser = authService.auth.currentUser;
      final owner = Owner(uid: currentUser!.uid, email: currentUser.email);
      await createOwnerInDb(owner);
    }
    return;
  }

  Future addGroup() async {
    // appState.updateNavBarSelection(NavBarSelection.group);
    Group group = Group(
      name: 'My Group',
      ownerUid: authService.auth.currentUser!.uid,
    );
    final groupId = await createGroupInDb(group);
    final groupRef = FirebaseFirestore.instance.collection('groups').doc(groupId);
    updateOwner(authService.auth.currentUser!.uid, {
      'groups': FieldValue.arrayUnion([groupRef])
    });
  }

  Future addEmployeesToDb() async {
    // appState.updateNavBarSelection(NavBarSelection.addEmployee);
    final result = await registerEmployeeAnonymously();
    print('registerEmployeeAnonymously result: ${result.credential}');
  }
}
