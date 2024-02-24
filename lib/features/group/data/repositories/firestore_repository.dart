import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:googleapis/driveactivity/v2.dart';

class FirestoreRepository {
  final FirebaseFirestore db;
  FirestoreRepository({required this.db});
  Future<String> addOwnerToDb(Owner owner) async {
    // Add owner to db
    return 'Owner added to db';
  }
}
