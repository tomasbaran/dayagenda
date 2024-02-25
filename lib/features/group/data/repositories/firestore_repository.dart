import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayagenda/features/group/domain/entities/owner.dart';

class FirestoreRepository {
  final FirebaseFirestore db;
  FirestoreRepository({required this.db});

  Future<bool> createOwnerInDb(Owner owner) async {
    print('Adding owner to db...');
    final parsedOwner = {
      'uid': owner.uid,
      'email': owner.email,
    };
    db.collection('owners').doc(owner.uid).set(parsedOwner);
    return true;
  }
}
