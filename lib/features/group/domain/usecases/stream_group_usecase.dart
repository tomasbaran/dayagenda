import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dayagenda/features/group/data/repositories/firestore_repository.dart';

class StreamGroupUseCase {
  final FirestoreRepository _repository;
  StreamGroupUseCase(this._repository);

  Stream call(DocumentReference groupRef) {
    // Create a StreamController to create and control the stream
    final controller = StreamController<List<dynamic>>();

    final subs = _repository.subscribeToGroupData(groupRef);
    subs.onData((data) {
      final group = data.data() as Map<String, dynamic>;
      print('StreamGroupUseCase.group: $group');
      // controller.add(groupRefs);
    });

    // Return the stream from the controller
    return controller.stream;
  }
}
