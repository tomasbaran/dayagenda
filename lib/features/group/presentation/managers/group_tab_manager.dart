import 'package:dayagenda/features/group/domain/entities/group.dart';
import 'package:flutter/material.dart';

class GroupTabManager {
  final groups = ValueNotifier<List<Group>?>(null);
  final showAddGroupForm = ValueNotifier<bool>(false);

  showAddGroupFrom(bool value) {
    showAddGroupForm.value = value;
    groups.value ??= [];
  }

  addGroup(String groupName) {
    print('newGroup: $groupName');
  }
}
