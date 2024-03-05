import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayagenda/features/add_employee/domain/entities/employee.dart';
import 'package:dayagenda/features/group/domain/entities/group.dart';
import 'package:dayagenda/features/group/domain/entities/owner.dart';

class FirestoreRepository {
  final FirebaseFirestore db;
  FirestoreRepository({required this.db});

  Future<bool> createOwner(Owner owner) async {
    print('Adding owner to db...');
    final parsedOwner = {
      'uid': owner.uid,
      'email': owner.email,
    };
    await db.collection('owners').doc(owner.uid).set(parsedOwner);
    return true;
  }

  Future<String> createGroup(Group group) async {
    print('Adding group to db...');
    final parsedGroup = {
      'name': group.name,
      'owner_uid': group.ownerUid,
    };
    final ref = await db.collection('groups').add(parsedGroup);
    return ref.id;
  }

  // Stream<List<Group>>

  StreamSubscription subscribeToOwnerData(String ownerUid) => db.collection('owners').doc(ownerUid).snapshots().listen((event) {});

  StreamSubscription subscribeToGroupData(DocumentReference groupRef) => groupRef.snapshots().listen((event) {});

  Future<bool> updateOwner(String ownerUid, Map<String, Object?> updatedMap) async {
    print('Updating owner in db...');
    await db.collection('owners').doc(ownerUid).set(updatedMap, SetOptions(merge: true));
    return true;
  }

  Future<bool> addEmployeeToEmployeesCollection(Employee employee) async {
    print('Adding employee: ${employee.uid} to employees collection...');
    final parsedEmployee = {
      'first_name': employee.firstName,
      'second_name': employee.secondName,
      'third_name': employee.thirdName,
      'phone': employee.phone,
      'status': employee.status.name,
      'uid': employee.uid,
      'email': employee.email,
    };
    await db.collection('employees').doc(employee.uid).set(parsedEmployee);
    return true;
  }

  Future<bool> addEmployeeToGroupsCollection(Group group, Employee employee) async {
    print('Adding employee: $employee to groups collection...');
    final DocumentReference employeeRef = db.collection('employees').doc(employee.uid);
    await db.collection('groups').doc(group.id).update({
      'employees': FieldValue.arrayUnion([employeeRef])
    });
    return true;
  }
}
