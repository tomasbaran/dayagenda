import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
              style: navBarAccountInformationTextStyle,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Log Out',
              style: navBarAccountTextStyle,
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: navBarAccountInformationTextStyle.color,
                borderRadius: BorderRadius.all(Radius.circular(6)),
              ),
              padding: EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.commentAlt,
                    color: navBarAccountHighlightedTextStyle.color,
                    size: 20,
                  ),
                  const SizedBox(width: 16),
                  Text(
                    'SEND FEEDBACK',
                    style: navBarAccountHighlightedTextStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
