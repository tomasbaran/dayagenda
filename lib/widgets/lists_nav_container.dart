import 'package:flutter/material.dart';
import 'package:today/style/style_constants.dart';

class ListsNavContainer extends StatelessWidget {
  const ListsNavContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // shrinkWrap: true,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(
              'Lists are coming soon.',
              style: navBarListTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
