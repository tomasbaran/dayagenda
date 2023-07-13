import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:today/style/style_constants.dart';

class TaskTimeTile extends StatelessWidget {
  const TaskTimeTile({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    this.disabled = false,
  });
  final bool disabled;
  final String title;
  final IconData icon;
  final String? value;

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile.notched(
      leadingToTitle: cupertinoListTileLeadingToTitle,
      leadingSize: cupertinoListTileLeadingSize,
      leading: Align(
        alignment: Alignment.centerLeft,
        child: Row(
          children: [
            Icon(
              icon,
              color: disabled ? kThemeColor3 : kThemeColor9,
            ),
            const SizedBox(
              width: 8,
            ),
            Text(
              title,
              style: addNewTaskSheetFieldTitleTextStyle.copyWith(color: disabled ? kThemeColor3 : null),
            ),
          ],
        ),
      ),
      title: Text(
        value ?? 'not assigned',
        style: addNewTaskSheetFieldHintTitleTextStyle.copyWith(color: (value == null || disabled) ? null : kThemeColor10),
      ),
    );
  }
}
