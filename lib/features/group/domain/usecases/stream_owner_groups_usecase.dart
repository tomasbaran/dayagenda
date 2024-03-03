import 'dart:async';

import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';

class StreamOwnerGroupsUseCase {
  final FirestoreRepository _repository;
  StreamOwnerGroupsUseCase(this._repository);

  Stream call(String ownerUid) {
    // Create a StreamController to create and control the stream
    final controller = StreamController<List<dynamic>>();

    final subs = _repository.subscribeToOwnerData(ownerUid);
    subs.onData((data) {
      final owner = data.data() as Map<String, dynamic>;
      final groupRefs = owner['groups'];
      controller.add(groupRefs);
    });

    // Return the stream from the controller
    return controller.stream;
  }
}
