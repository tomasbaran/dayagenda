import 'package:dayagenda/services/service_locator.dart';
import 'package:dayagenda/states/list_state/list_state.dart';
import 'package:flutter/material.dart';
import 'package:dayagenda/style/style_constants.dart';

class ListsNavContainer extends StatelessWidget {
  ListsNavContainer({super.key});
  final listState = getIt<ListState>();

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
          ListView.builder(
            itemBuilder: (context, index) => ListTile(
              title: Text(
                listState.idLists[index].title.toString(),
                style: navBarListTextStyle,
                textAlign: TextAlign.center,
              ),
            ),
            itemCount: listState.idLists.length,
            shrinkWrap: true,
          ),
        ],
      ),
    );
  }
}
