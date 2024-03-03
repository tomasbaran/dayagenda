import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/features/add_employee/domain/usecases/send_invitation_message_to_employees.dart';
import 'package:dayagenda/features/group/domain/entities/group.dart';
import 'package:dayagenda/features/group/domain/entities/owner.dart';
import 'package:dayagenda/features/group/domain/usecases/add_employee_to_employees_collection_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/add_employee_to_groups_collection_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/add_group_id_to_owner_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/create_group_in_db_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/create_owner_in_db_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/stream_owner_groups_usecase.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/states/auth_state.dart';
import 'package:flutter/material.dart';

class GroupTabManager {
  final CreateOwnerInDbUsecase createOwnerInDb;
  final CreateGroupInDbUsecase createGroupInDb;
  final UpdateOwnerUsecase updateOwner;
  final SendInvitationMessageToEmployees sendInvitationMessageToEmployees;
  final AddEmployeeToEmployeesCollectionUsecase addEmployeeToEmployeesCollection;
  final AddEmployeeToGroupsCollectionUsecase addEmployeeToGroupsCollection;
  final StreamOwnerGroupsUseCase streamOwnerGroups;
  GroupTabManager({
    required this.streamOwnerGroups,
    required this.createOwnerInDb,
    required this.createGroupInDb,
    required this.updateOwner,
    required this.sendInvitationMessageToEmployees,
    required this.addEmployeeToEmployeesCollection,
    required this.addEmployeeToGroupsCollection,
  });
  final appState = locate<AppState>();
  final authService = locate<AuthService>();

  final groups = ValueNotifier<List<Group>?>(null);
  final showAddGroupForm = ValueNotifier<bool>(false);

  Future subscribeToGroups() async {
    final groupSubscription = streamOwnerGroups(authService.auth.currentUser!.uid);
    groupSubscription.listen((event) {
      event.forEach((group) {
        print('group: $group');
      });
    });
  }

  Future tapAddGroupIcon() async {
    showAddGroupForm.value = true;
    groups.value ??= [];

    final currentUser = authService.auth.currentUser;
    final owner = Owner(uid: currentUser!.uid, email: currentUser.email);
    await createOwnerInDb(owner);
    return;
  }

  Future addGroup(String groupName) async {
    // appState.updateNavBarSelection(NavBarSelection.group);
    Group group = Group(
      name: groupName,
      ownerUid: authService.auth.currentUser!.uid,
    );
    final groupId = await createGroupInDb(group);
    final groupRef = FirebaseFirestore.instance.collection('groups').doc(groupId);
    updateOwner(authService.auth.currentUser!.uid, {
      'groups': FieldValue.arrayUnion([groupRef])
    });
  }

  Future addEmployeesToDb({required List<Employee> employees, required Group group}) async {
    // appState.updateNavBarSelection(NavBarSelection.addEmployee);

    final authState = locate<AuthState>();
    final AuthService authService = locate<AuthService>();

    final appState = locate<AppState>();
    // step 1: owner logout : to be able to use signInAnonymously for the employees
    await authService.logout();

    // step 2: register employees
    for (var employee in employees) {
      // step A: register employee anonymously
      final employeeCredentials = await authService.signInAnonymously();
      employee.uid = employeeCredentials?.user?.uid;
      print('registerEmployeeAnonymously employeeUid: $employee');

      // step B: add employee to employees collection
      await addEmployeeToEmployeesCollection(employee);
      print('added employee[${employee.uid}] to employees collection');

      // step C: add employee to group collection
      await addEmployeeToGroupsCollection(group, employee);
      // print('updated group collection with a new employee member: Employee.uid: ${employee.uid}');

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
