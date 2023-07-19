import 'package:flutter/material.dart';
import 'package:today/managers/list_manager.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';
import 'package:today/widgets/task_card.dart';

class CompletedTasksColumn extends StatelessWidget {
  final listManager = getIt<ListManager>();
  CompletedTasksColumn({
    super.key,
  });

  List<Widget> children() {
    double emptySpaceHeight = listManager.calcEmptySpaceHeight();

    List<Widget> output = [];
    output.add(
      Padding(
        padding: EdgeInsets.only(top: emptySpaceHeight < minEmptySpaceHeight ? minEmptySpaceHeight : emptySpaceHeight),
        child: Center(
          child: Text(
            'COMPLETED: ${listManager.selectedList.value.completedTasks.length}',
          ),
        ),
      ),
    );
    if (listManager.selectedList.value.completedTasks.isNotEmpty) {
      output.add(const SizedBox(height: completedTitleBottomPadding));
    }
    for (var completedTask in listManager.selectedList.value.completedTasks) {
      output.add(TaskCard(
        task: completedTask,
      ));
    }
    return output;
  }

  @override
  Widget build(BuildContext context) {
    // onLongPress: ()=>{} makes it NOT reorderable
    return GestureDetector(
      onLongPress: () => {
        // print('holdme')
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children(),
      ),
    );
  }
}
