import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayagenda/features/group/domain/entities/owner.dart';

class FirestoreRepository {
  final FirebaseFirestore db;
  FirestoreRepository({required this.db});
  Future<String> addOwnerToDb(Owner owner) async {
    // Add owner to db
    print('Adding owner to db...');
    return 'Owner added to db';
  }
}
