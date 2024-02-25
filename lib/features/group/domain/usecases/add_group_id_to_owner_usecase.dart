import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';

class UpdateOwnerUsecase {
  final FirestoreRepository repository;
  UpdateOwnerUsecase({required this.repository});

  Future<String> call(String ownerUid, Map<Object, Object?> updatedMap) async => await repository.updateOwner(ownerUid, updatedMap);
}
