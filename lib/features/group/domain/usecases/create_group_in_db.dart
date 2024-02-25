import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';
import 'package:dayagenda/features/group/domain/entities/group.dart';

class CreateGroupInDb {
  final FirestoreRepository repository;
  CreateGroupInDb(this.repository);

  call(Group group) async {
    return await repository.createGroup(group);
  }
}
