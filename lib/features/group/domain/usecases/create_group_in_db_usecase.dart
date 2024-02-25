import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';
import 'package:dayagenda/features/group/domain/entities/group.dart';

class CreateGroupInDbUsecase {
  final FirestoreRepository repository;
  CreateGroupInDbUsecase(this.repository);

  Future<String> call(Group group) async => await repository.createGroup(group);
}
