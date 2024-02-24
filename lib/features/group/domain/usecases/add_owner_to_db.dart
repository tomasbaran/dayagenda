import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';
import 'package:googleapis/driveactivity/v2.dart';

class AddOwnerToDb {
  final FirestoreRepository repository;

  AddOwnerToDb(this.repository);

  Future<String> call(Owner owner) async {
    return await repository.addOwnerToDb(owner);
  }
}
