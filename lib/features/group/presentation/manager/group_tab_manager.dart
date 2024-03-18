import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/features/add_employee/domain/usecases/send_invitation_message_to_employees.dart';
import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';
import 'package:dayagenda/features/group/domain/entities/group.dart';
import 'package:dayagenda/features/group/domain/entities/owner.dart';
import 'package:dayagenda/features/group/domain/usecases/add_employee_to_employees_collection_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/add_employee_to_groups_collection_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/add_group_to_owner_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/create_group_in_db_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/create_owner_in_db_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/stream_group_usecase.dart';
import 'package:dayagenda/features/group/domain/usecases/stream_group_refs_usecase.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/services/auth_service/auth_service.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/states/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dayagenda/firebase_options_dev.dart' as dev;

class GroupTabManager {
  final CreateOwnerInDbUsecase createOwnerInDbUseCase;
  final CreateGroupInDbUsecase createGroupInDb;
  final AddGroupToOwnerUseCase addGroupToOwner;
  final SendInvitationMessageToEmployees sendInvitationMessageToEmployees;
  final AddEmployeeToEmployeesCollectionUsecase addEmployeeToEmployeesCollection;
  final AddEmployeeToGroupsCollectionUsecase addEmployeeToGroupsCollection;
  final StreamGroupRefsUseCase streamGroupRefs;
  final StreamGroupUseCase streamGroups;
  GroupTabManager({
    required this.addGroupToOwner,
    required this.streamGroups,
    required this.streamGroupRefs,
    required this.createOwnerInDbUseCase,
    required this.createGroupInDb,
    required this.sendInvitationMessageToEmployees,
    required this.addEmployeeToEmployeesCollection,
    required this.addEmployeeToGroupsCollection,
  });
  final appState = locate<AppState>();
  final authService = locate<AuthService>();
  Owner? owner;

  final groups = ValueNotifier<List<Group>?>(null);
  final isGroupsStreamInitialized = ValueNotifier<bool>(false);
  final firestoreRepo = locate<FirestoreRepository>();

  Future<Owner?> getOwnerOrNull() {
    return firestoreRepo.checkDocumentExists('owners/${authService.auth.currentUser!.uid}').then((exists) async {
      if (exists) {
        final Map<String, dynamic>? ownerData = await firestoreRepo.getOwnerData(authService.auth.currentUser!.uid);
        final Owner owner = Owner(
          uid: ownerData?['uid'],
          email: ownerData?['email'],
        );
        return owner;
      } else {
        return null;
      }
    });
  }

  subscribeToGroups() async {
    owner = await getOwnerOrNull();
    if (!isGroupsStreamInitialized.value && owner != null) {
      isGroupsStreamInitialized.value = true;
      final groupRefsSubscription = streamGroupRefs(authService.auth.currentUser!.uid);
      groups.value = []; // Initialize your groups list

      groupRefsSubscription.listen((groupRefEvent) {
        groupRefEvent.forEach((groupRef) {
          final groupsSubscription = streamGroups(groupRef);
          groupsSubscription.listen((updatedGroup) {
            // Find if the group already exists
            var existingGroupIndex = groups.value?.indexWhere((g) => g.id == updatedGroup.id);

            if (existingGroupIndex != null && existingGroupIndex != -1) {
              // If exists, update the existing group
              groups.value![existingGroupIndex] = updatedGroup;
            } else {
              // If doesn't exist, add as a new group
              groups.value?.add(updatedGroup);
            }

            // To trigger the ValueNotifier, set it to a new list containing the updated groups
            groups.value = List.from(groups.value!);
          });
        });
      });
    }
  }

  Future createOwnerInDbIfNotCreatedYet() async {
    if (owner == null) {
      final currentUser = authService.auth.currentUser;
      owner = Owner(uid: currentUser!.uid, email: currentUser.email);
      await createOwnerInDbUseCase(owner!);
    }
    subscribeToGroups();
    return;
  }

  Future addGroup(String groupName) async {
    // appState.updateNavBarSelection(NavBarSelection.group);
    // 0. clear employees of the group
    // groups.value = [];
    // 1. create group
    Group group = Group(
      name: groupName,
      ownerUid: authService.auth.currentUser!.uid,
    );
    final groupId = await createGroupInDb(group);
    // 2. add group to owner
    await addGroupToOwner(ownerUid: authService.auth.currentUser!.uid, groupId: groupId);
    return;
  }

  Future addEmployeesToDb({required List<Employee> employees, required Group group}) async {
    // appState.updateNavBarSelection(NavBarSelection.addEmployee);

    final authState = locate<AuthState>();
    final appState = locate<AppState>();

    // Register a new FirebaseApp for Employees
    final employeeAuthService =
        FirebaseAuth.instanceFor(app: await Firebase.initializeApp(name: 'employees', options: dev.DefaultFirebaseOptions.currentPlatform));

    // step 2: register employees
    for (var employee in employees) {
      // step A: register employee anonymously
      final employeeCredentials = await employeeAuthService.signInAnonymously();
      employee.uid = employeeCredentials.user?.uid;
      print('registerEmployeeAnonymously employeeUid: $employee');

      // step B: add employee to employees collection
      await addEmployeeToEmployeesCollection(employee);
      print('added employee[${employee.uid}] to employees collection');

      // step C: add employee to group collection
      await addEmployeeToGroupsCollection(group, employee);
      // print('updated group collection with a new employee member: Employee.uid: ${employee.uid}');

      // logout the newly registered and signed in employee
      print('employeeCredentials: ${employeeCredentials.user?.uid}');
      await employeeAuthService.signOut();
    }

    // step 3: send invitation message to employees
    // await sendInvitationMessageToEmployees(employees);
    // step 4: owner login
    final lastUsedEmail = authState.lastUsedEmail;
    final lastUsedPassword = authState.lastUsedPassword;
    if (lastUsedPassword == null || lastUsedEmail == null) {
      appState.updateNavBarSelection(NavBarSelection.account);
    } else {
      await authState.loginWithEmailAndPassword(lastUsedEmail, lastUsedPassword);
    }
  }

  dispose() {
    streamGroupRefs.dispose();
    streamGroups.dispose();
    print('\x1B[35mdisposed streams!\x1B[0m');
  }
}
