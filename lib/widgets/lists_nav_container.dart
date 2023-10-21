import 'package:flutter/material.dart';
import 'package:dayagenda/style/style_constants.dart';

class ListsNavContainer extends StatelessWidget {
  const ListsNavContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // shrinkWrap: true,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Lists',
            style: navBarHeadlineTextStyle,
          ),
          const SizedBox(height: 24),
          Text(
            'Coming soon.',
            style: navBarListTextStyle,
          ),
        ],
      ),
    );
  }
}
