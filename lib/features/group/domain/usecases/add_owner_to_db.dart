import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';
import 'package:dayagenda/features/group/domain/entities/owner.dart';

class AddOwnerToDbUsecase {
  final FirestoreRepository repository;
  AddOwnerToDbUsecase(this.repository);

  Future<bool> call(Owner owner) async {
    return await repository.addOwnerToDb(owner);
  }
}
