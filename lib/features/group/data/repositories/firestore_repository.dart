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
    await db.collection('owners').doc(owner.uid).set(parsedOwner, SetOptions(merge: true));
    return true;
  }

  Future<Map<String, dynamic>?> getOwnerData(String ownerUid) async {
    try {
      DocumentSnapshot ownerDocument = await db.collection('owners').doc(ownerUid).get();

      if (ownerDocument.exists) {
        return ownerDocument.data() as Map<String, dynamic>?;
      } else {
        print('No data found for this owner UID.');
        return null;
      }
    } catch (e) {
      print('Error fetching owner data: $e');
      return null;
    }
  }

  Future<String> createGroup(Group group) async {
    print('Adding group to db...');
    final parsedGroup = {
      'name': group.name,
      'owner_uid': group.ownerUid,
    };
    try {
      final ref = await db.collection('groups').add(parsedGroup);
      return ref.id;
    } catch (e) {
      throw e;
    }
  }

  Future<bool> checkDocumentExists(String path) async {
    try {
      // Attempt to fetch the document at the specified path
      var document = await FirebaseFirestore.instance.doc(path).get();

      // Return true if the document exists, false if it doesn't
      return document.exists;
    } catch (e) {
      // Handle any errors, such as network issues, permissions, etc.
      print('Error checking document existence: $e');
      return false;
    }
  }

  // Stream<List<Group>>

  StreamSubscription subscribeToOwnerData(String ownerUid) => db.collection('owners').doc(ownerUid).snapshots().listen((event) {
        print('Owner data: ${event.data()}');
      });

  StreamSubscription subscribeToGroupData(DocumentReference groupRef) {
    print('Subscribing to group data: $groupRef');

    return groupRef.snapshots().listen((event) {
      print('event: $event');
    });
  }

  Future<bool> migrateTmpEmployeeToEmployee(
    Employee employee,
    /*  String tmpEmployeeId, String employeeUid, String email, String firstName */
  ) async {
    print('Updating employee in db...');
    final tmpEmployeeInfo = await db.collection('tmp_employees_info').doc(employee.tmpId).get();
    final tmpEmployeeInfoData = tmpEmployeeInfo.data();

    final nickname = tmpEmployeeInfoData!['nickname'];
    final phone = tmpEmployeeInfoData['phone'];
    final groupId = tmpEmployeeInfoData['group_id'];

    final Map<String, dynamic> employeeData = {
      'nickname': nickname,
      'phone': phone,
      'uid': employee.uid,
      'email': employee.email,
      'first_name': employee.firstName,
    };

    print('tmpEmployeeId: ${employee.tmpId}');
    print('employeeUid: ${employee.uid}');
    await db.collection('employees').doc(employee.uid).set(employeeData, SetOptions(merge: true));

    // Update the employee in the group with the new employee data: remove tmp_id and add uid
    await db.collection('groups').doc(groupId).update({
      'employees': FieldValue.arrayRemove([
        {
          'nickname': nickname,
          'phone': phone,
          'tmp_id': employee.tmpId,
          'uid': null,
          'status': 'invitationSent',
        }
      ])
    });
    await db.collection('groups').doc(groupId).update({
      'employees': FieldValue.arrayUnion([
        {
          'nickname': nickname,
          'phone': phone,
          'uid': employee.uid,
          'status': 'registered',
        }
      ])
    });

    // Delete the tmp employee info document
    await db.collection('tmp_employees_info').doc(employee.tmpId).delete();
    return true;
  }

  Future<bool> updateGroupEmployee(String groupId, Employee oldEmployee, Employee newEmployee) async {
    print('Updating group in db...');
    print('\x1B[32moldEmployee: $oldEmployee\x1B[0m');

    await db.collection('groups').doc(groupId).update({
      'employees': FieldValue.arrayRemove([
        {
          'nickname': oldEmployee.nickname,
          'phone': oldEmployee.phone,
          'tmp_id': oldEmployee.tmpId,
          'uid': oldEmployee.uid,
          'status': oldEmployee.status.name.toString(),
        }
      ])
    });
    await db.collection('groups').doc(groupId).update({
      'employees': FieldValue.arrayUnion([
        {
          'nickname': newEmployee.nickname,
          'phone': newEmployee.phone,
          'tmp_id': newEmployee.tmpId,
          'uid': newEmployee.uid,
          'status': newEmployee.status.name.toString(),
        }
      ])
    });
    return true;
  }

  Future<bool> updateOwner(String ownerUid, Map<String, Object?> updatedMap) async {
    print('Updating owner in db...');
    await db.collection('owners').doc(ownerUid).update(updatedMap);
    return true;
  }

  Future<bool> addGroupRefToOwner({required String ownerUid, required String groupId}) async {
    try {
      DocumentReference groupRef = db.collection('groups').doc(groupId);
      await db.collection('owners').doc(ownerUid).update({
        'groups': FieldValue.arrayUnion([groupRef])
      });
      print('Added group ref to owner');
    } catch (e) {
      throw e;
    }

    return true;
  }

  Future<Employee> updateTmpEmployeeInfo(Employee employee) async {
    print('\x1B[33m Update employee: ${employee} in tmp employee info collection... \x1B[0m');
    final tmpEmployeeRef = db.collection('tmp_employees_info').doc(employee.tmpId);
    final updatedEmployee = Employee(
      nickname: employee.nickname,
      phone: employee.phone,
      status: employee.status,
      tmpId: tmpEmployeeRef.id,
      uid: employee.uid,
      email: employee.email,
      groupId: employee.groupId,
    );

    print(' \x1B[31m1: tmpEmployeeRef: ${tmpEmployeeRef.id}');

    final parsedEmployee = {
      'nickname': updatedEmployee.nickname,
      // 'first_name': employee.firstName,
      // 'second_name': employee.secondName,
      // 'third_name': employee.thirdName,
      'phone': updatedEmployee.phone,
      'status': updatedEmployee.status.name,
      'tmp_id': updatedEmployee.tmpId,
      // 'uid': employee.uid,
      // 'email': employee.email,
      'group_id': employee.groupId,
    };

    tmpEmployeeRef.set(parsedEmployee, SetOptions(merge: true));
    return updatedEmployee;
  }

  Future<bool> addEmployeeToGroupsCollection(Group group, Employee employee) async {
    print('Adding employee: $employee to groups collection: $group');
    // final DocumentReference employeeRef = db.collection('employees').doc(employee.uid);
    Map<String, dynamic> employeeMap = {
      'nickname': employee.nickname,
      'phone': employee.phone,
      'uid': employee.uid,
      'tmp_id': employee.tmpId,
      'status': employee.status.name.toString(),
    };
    await db.collection('groups').doc(group.id).update({
      'employees': FieldValue.arrayUnion([employeeMap])
    });
    return true;
  }
}
