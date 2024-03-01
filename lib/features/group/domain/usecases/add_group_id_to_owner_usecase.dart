import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';

class UpdateOwnerUsecase {
  final FirestoreRepository repository;
  UpdateOwnerUsecase({required this.repository});

  Future<bool> call(String ownerUid, Map<String, Object?> updatedMap) async => await repository.updateOwner(ownerUid, updatedMap);
}
