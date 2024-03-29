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

  Future<bool> updateEmployee(String tmpEmployeeId, String employeeUid, String email, String firstName) async {
    print('Updating employee in db...');
    final tmpEmployeeInfo = await db.collection('tmp_employees_info').doc(tmpEmployeeId).get();
    final tmpEmployeeInfoData = tmpEmployeeInfo.data();

    final nickname = tmpEmployeeInfoData!['nickname'];
    final phone = tmpEmployeeInfoData['phone'];

    final Map<String, dynamic> employeeData = {
      'nickname': nickname,
      'employee_status': 'registered',
      'phone': phone,
      'uid': employeeUid,
      'email': email,
      'first_name': firstName,
    };

    print('tmpEmployeeId: $tmpEmployeeId');
    print('employeeUid: $employeeUid');
    await db.collection('employees').doc(employeeUid).set(employeeData, SetOptions(merge: true));
    return true;
  }

  Future<bool> updateGroupEmployee(String groupId, Employee oldEmployee, Employee newEmployee) async {
    print('Updating group in db...');
    await db.collection('groups').doc(groupId).update({
      'employees': FieldValue.arrayRemove([
        {
          'nickname': oldEmployee.nickname,
          'phone': oldEmployee.phone,
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

  Future<bool> addEmployeeToEmployeesCollection(Employee employee) async {
    print('Adding employee: ${employee.uid} to employees collection...');
    final parsedEmployee = {
      'nickname': employee.nickname,
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
    print('Adding employee: $employee to groups collection: $group');
    // final DocumentReference employeeRef = db.collection('employees').doc(employee.uid);
    Map<String, dynamic> employeeMap = {
      'nickname': employee.nickname,
      'phone': employee.phone,
      'uid': employee.uid,
      'status': employee.status.name.toString(),
    };
    await db.collection('groups').doc(group.id).update({
      'employees': FieldValue.arrayUnion([employeeMap])
    });
    return true;
  }
}
