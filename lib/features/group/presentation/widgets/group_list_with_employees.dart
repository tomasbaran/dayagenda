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
        Row(
          children: [
            const SizedBox(
              height: 48,
              width: 48,
            ),
            Expanded(
              child: Text(
                group.name.toUpperCase(),
                style: navBarAccountHighlightedTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: CircleAvatar(
                radius: 12,
                child: Icon(
                  Icons.person_add_alt_outlined,
                  size: 18,
                  color: groupColors[id],
                ),
              ),
            ),
          ],
        ),
        for (var employee in group.employees) Text(employee.firstName, style: navBarAccountEmailInputTextStyle.copyWith(color: groupColors[id])),
        const SizedBox(height: 24),
      ],
    );
  }
}
