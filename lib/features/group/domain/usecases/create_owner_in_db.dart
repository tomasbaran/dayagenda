import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';
import 'package:dayagenda/features/group/domain/entities/owner.dart';

class CreateOwnerInDbUsecase {
  final FirestoreRepository repository;
  CreateOwnerInDbUsecase({required this.repository});

  Future<bool> call(Owner owner) async {
    return await repository.createOwner(owner);
  }
}
