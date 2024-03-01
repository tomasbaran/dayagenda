import 'package:dayagenda/features/group/presentation/widgets/no_groups_description.dart';
import 'package:dayagenda/style/style_constants.dart';
import 'package:flutter/material.dart';

class NoGroups extends StatelessWidget {
  const NoGroups({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Text(
            'Mis Grupos',
            style: navBarHeadlineTextStyle,
          ),
          const SizedBox(height: 24),
          const NoGroupsDescription(),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.bottomRight,
            child: IconButton(
              onPressed: null,
              icon: Icon(
                Icons.add_circle_rounded,
                size: 32,
                color: kBlueAccentColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
