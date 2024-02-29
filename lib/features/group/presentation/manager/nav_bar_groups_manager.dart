import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/features/add_employee/domain/usecases/send_invitation_message_to_employees.dart';
import 'package:dayagenda/features/group/domain/entities/group.dart';
import 'package:dayagenda/features/group/domain/entities/owner.dart';
import 'package:dayagenda/features/group/domain/usecases/add_group_id_to_owner_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/create_group_in_db_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/create_owner_in_db_usecase.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/states/auth_state.dart';

class NavBarGroupsManager {
  final CreateOwnerInDbUsecase createOwnerInDb;
  final CreateGroupInDbUsecase createGroupInDb;
  final UpdateOwnerUsecase updateOwner;
  final SendInvitationMessageToEmployees sendInvitationMessageToEmployees;
  NavBarGroupsManager({
    required this.createOwnerInDb,
    required this.createGroupInDb,
    required this.updateOwner,
    required this.sendInvitationMessageToEmployees,
  });
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

  Future addEmployeesToDb(List<Employee> employees) async {
    // appState.updateNavBarSelection(NavBarSelection.addEmployee);

    final authState = locate<AuthState>();
    final AuthService authService = locate<AuthService>();

    final appState = locate<AppState>();
    // step 1: owner logout : to be able to use signInAnonymously for the employees
    await authService.logout();

    // step 2: register employees
    for (var employee in employees) {
      final employeeCredentials = await authService.signInAnonymously();
      final employeeUid = employeeCredentials?.user?.uid;
      employee.uid = employeeUid;

      print('registerEmployeeAnonymously employeeUid: $employeeUid');
      await authService.logout();
    }
    // step 3: send invitation message to employees
    await sendInvitationMessageToEmployees(employees);
    // step 4: owner login
    final lastUsedEmail = authState.lastUsedEmail;
    final lastUsedPassword = authState.lastUsedPassword;
    if (lastUsedPassword == null || lastUsedEmail == null) {
      appState.updateNavBarSelection(NavBarSelection.account);
    } else {
      await authState.loginWithEmailAndPassword(lastUsedEmail, lastUsedPassword);
    }
  }
}
