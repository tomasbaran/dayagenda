import 'package:cloud_firestore/cloud_firestore.dart';
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
}
