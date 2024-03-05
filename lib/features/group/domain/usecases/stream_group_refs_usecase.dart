import 'dart:async';
import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';

class StreamGroupRefsUseCase {
  final FirestoreRepository _repository;
  StreamGroupRefsUseCase(this._repository);
  late StreamController controller;

  Stream call(String ownerUid) {
    // Create a StreamController to create and control the stream
    controller = StreamController<List<dynamic>>();
    final subs = _repository.subscribeToOwnerData(ownerUid);
    subs.onData((data) {
      final owner = data.data() as Map<String, dynamic>;
      final groupRefs = owner['groups'];
      print('StreamOwnerGroupsUseCase.groupRefs: $groupRefs');
      if (groupRefs != null) {
        controller.add(groupRefs);
      }
    });

    // Return the stream from the controller
    return controller.stream;
  }

  dispose() {
    controller.close();
  }
}
