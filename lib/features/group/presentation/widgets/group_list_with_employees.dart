import 'package:dayagenda/features/group/domain/entities/group.dart';
import 'package:dayagenda/style/style_constants.dart';
import 'package:flutter/material.dart';

class GroupListWithEmployees extends StatelessWidget {
  const GroupListWithEmployees({
    super.key,
    required this.group,
    required this.id,
  });
  final int id;
  final Group group;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(group.name.toUpperCase(), style: navBarAccountHighlightedTextStyle),
        for (var employee in group.employees) Text(employee.firstName, style: navBarAccountEmailInputTextStyle.copyWith(color: groupColors[id])),
        const SizedBox(height: 24),
      ],
    );
  }
}
