import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';

class AddGroupIdToOwnerUsecase {
  final FirestoreRepository repository;
  AddGroupIdToOwnerUsecase({required this.repository});

  Future<String> call(String ownerUid, String groupId) async => await repository.updateOwner(ownerUid, {'groupId': groupId});
}
