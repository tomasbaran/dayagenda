import 'package:dayagenda/features/group/domain/entities/group.dart';
import 'package:flutter/material.dart';

class NoGroupsManager {
  final groups = ValueNotifier<List<Group>?>(null);
  final showAddGroupForm = ValueNotifier<bool>(false);

  showAddGroupFrom(bool value) {
    showAddGroupForm.value = value;
    groups.value ??= [];
  }
}
