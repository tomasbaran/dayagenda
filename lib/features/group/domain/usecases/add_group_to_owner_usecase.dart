import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';

class AddGroupToOwnerUseCase {
  final FirestoreRepository _repository;
  AddGroupToOwnerUseCase(this._repository);

  Future<void> call({required String groupId, required String ownerUid}) async =>
      await _repository.addGroupRefToOwner(ownerUid: ownerUid, groupId: groupId);
}
