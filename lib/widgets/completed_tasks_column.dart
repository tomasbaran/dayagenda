import 'package:dayagenda/utils/date_time_utils.dart';
import 'package:flutter/material.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/states/list_state/list_state.dart';
import 'package:dayagenda/services/service_locator.dart';
import 'package:dayagenda/style/style_constants.dart';
import 'package:dayagenda/widgets/task_card.dart';
import 'package:universal_platform/universal_platform.dart';

class CompletedTasksColumn extends StatelessWidget {
  final listState = getIt<ListState>();
  final appState = getIt<AppState>();
  CompletedTasksColumn({
    super.key,
  });

  List<Widget> children(BuildContext context) {
    List<Widget> output = [];
    output.add(
      Visibility(
        visible: !listState.dateState.selectedDate.value.isBefore(DateTimeUtils.resetTimeToZero(DateTime.now())),
        child: Padding(
          padding: EdgeInsets.only(
              top:
                  // if the selected list is before today, don't show the completedTasksColumn top padding
                  listState.dateState.selectedDate.value.isBefore(DateTimeUtils.resetTimeToZero(DateTime.now()))
                      ? 8
                      : appState.emptySpaceHeight(listState.selectedList.value.tasks.length, context) < minEmptySpaceHeight
                          ? minEmptySpaceHeight
                          : appState.emptySpaceHeight(listState.selectedList.value.tasks.length, context)),
          child: Center(
            child: Text(
              'COMPLETED: ${listState.selectedList.value.completedTasks.length}',
            ),
          ),
        ),
      ),
    );
    if (listState.selectedList.value.completedTasks.isNotEmpty) {
      output.add(SizedBox(
          height: // if the selected list is before today, don't show the completedTasksColumn top padding
              listState.dateState.selectedDate.value.isBefore(DateTimeUtils.resetTimeToZero(DateTime.now()))
                  ? 8
                  : UniversalPlatform.isAndroid || UniversalPlatform.isIOS
                      ? mobileCompletedTitleBottomPadding
                      : desktopCompletedTitleBottomPadding));
    }
    for (var completedTask in listState.selectedList.value.completedTasks) {
      output.add(TaskCard(
        task: completedTask,
      ));
    }
    output.add(SizedBox(
        height: UniversalPlatform.isAndroid || UniversalPlatform.isIOS ? mobileCompletedTitleBottomPadding : desktopCompletedTitleBottomPadding));
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
        children: children(context),
      ),
    );
  }
}
