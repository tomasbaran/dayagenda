import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/states/date_state.dart';
import 'package:dayagenda/models/my_list.dart';
import 'package:dayagenda/states/list_state/list_state.dart';
import 'package:dayagenda/services/service_locator.dart';
import 'package:dayagenda/widgets/completed_tasks_column.dart';
import 'package:dayagenda/widgets/task_card.dart';

import '../globals/constants.dart';

class TasksContainer extends StatelessWidget {
  TasksContainer({
    Key? key,
  }) : super(key: key);

  final listState = getIt<ListState>();
  final appState = getIt<AppState>();
  final dateState = getIt<DateState>();

  @override
  Widget build(BuildContext context) {
    final pageController = appState.datePageController;
    return SafeArea(
      minimum: EdgeInsets.only(bottom: appState.floatingBottomSafeArea),
      child: PageView.builder(
        onPageChanged: (newPage) => listState.selectDateListByPage(pageController.page ?? todayIndex.toDouble(), newPage),
        controller: pageController,
        itemBuilder: (____, pageIndex) {
          return ValueListenableBuilder<MyList>(
              valueListenable: listState.selectedList,
              builder: (_, pageList, __) {
                int tasksCount = pageList.tasks.length - 1; // includes 0, e.g. taskCount 3 = 0,1,2,3
                // log('\x1B[34mupdate pageList [${pageList.title} | ${pageList.date}]: $tasksCount $pageList\x1B[0m');
                return ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    footer: CompletedTasksColumn(),
                    itemCount: pageList.tasks.length, // +1 is the new last item: Column of FillInHeight + COMPLETED:
                    itemBuilder: ((___, taskIndex) {
                      // reversedIndex is to show the newest task on top of the list
                      int reversedIndex = tasksCount - taskIndex;

                      Widget listItem = ReorderableDragStartListener(
                        key: Key(reversedIndex.toString()),
                        index: taskIndex,
                        child: TaskCard(
                          key: Key(reversedIndex.toString()),
                          task: pageList.tasks[reversedIndex],
                        ),
                      );

                      return listItem;
                    }),
                    // possible bugfix of scrollbug#2 by utilizing the below scrollController instead of using PageView's NotificationListener
                    // scrollController: ,
                    proxyDecorator: (_, taskIndex, animation) {
                      debugPrint('taskIndex: $taskIndex; lastIndex: $tasksCount');
                      // reversedIndex is to show the newest task on top of the list
                      int reversedIndex = tasksCount - taskIndex;
                      return AnimatedBuilder(
                        animation: animation,
                        builder: (_, __) {
                          final double animValue = Curves.easeOut.transform(animation.value);
                          final double elevation = lerpDouble(1, 8, animValue)!;
                          final scale = lerpDouble(1, 1.02, animValue)!;
                          return Transform.scale(
                            scale: scale,
                            child: TaskCard(
                              elevation: elevation,
                              task: pageList.tasks[reversedIndex],
                            ),
                          );
                        },
                      );
                    },
                    onReorder: (oldIndex, newIndex) {
                      debugPrint('oldIndex: $oldIndex; lastIndex: $tasksCount');
                      int reversedOldIndex = tasksCount - oldIndex;
                      int reversedNewIndex = tasksCount - newIndex;
                      listState.reorderList(reversedOldIndex, reversedNewIndex);
                    });
              });
        },
      ),
    );
  }
}
