import 'package:flutter/material.dart';
import 'package:today/style/style_constants.dart';

class AccountNavContainer extends StatelessWidget {
  const AccountNavContainer({super.key});

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
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'signed in as name@mail.com',
              style: navBarListTextStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'SEND FEEDBACK',
              style: navBarListTextStyle,
            ),
          ),
        ],
      ),
    );
  }
}
