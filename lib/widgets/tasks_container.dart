import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:today/states/app_state.dart';
import 'package:today/states/date_state.dart';
import 'package:today/models/my_list.dart';
import 'package:today/states/list_state/list_state.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/widgets/completed_tasks_column.dart';
import 'package:today/widgets/task_card.dart';

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
                int tasksCount = pageList.tasks.length;
                int listWidgetsCount = tasksCount + 1; // +1 is the new last item: Column of FillInHeight + COMPLETED:
                log('\x1B[34mupdate pageList: $tasksCount ${pageList}\x1B[0m');
                return ReorderableListView.builder(
                    itemCount: listWidgetsCount, // +1 is the new last item: Column of FillInHeight + COMPLETED:
                    itemBuilder: ((___, taskIndex) {
                      // reversedIndex is to show the newest task on top of the list
                      int reversedIndex = tasksCount - 1 - taskIndex;
                      // Add CompletedTasksColumn as the last item in the ListView
                      if (taskIndex == tasksCount) {
                        return CompletedTasksColumn(
                          key: const Key('last'),
                        );
                      } else {
                        return TaskCard(
                          key: Key(reversedIndex.toString()),
                          task: pageList.tasks[reversedIndex],
                        );
                      }
                    }),
                    // possible bugfix of scrollbug#2 by utilizing the below scrollController instead of using PageView's NotificationListener
                    // scrollController: ,
                    proxyDecorator: (_, taskIndex, animation) {
                      debugPrint('taskIndex: $taskIndex; lastIndex: $tasksCount');
                      // Don't animate lastIndex
                      if (taskIndex == tasksCount) {
                        // print('taskIndex: not animating the lastIndex');
                        return const SizedBox();
                      } else {
                        // reversedIndex is to show the newest task on top of the list
                        int reversedIndex = tasksCount - 1 - taskIndex;
                        return AnimatedBuilder(
                          animation: animation,
                          builder: (_, __) {
                            final double animValue = Curves.easeOut.transform(animation.value);
                            final double elevation = lerpDouble(1, 6, animValue)!;
                            final scale = lerpDouble(1, 1.02, animValue)!;
                            return Transform.scale(
                              scale: scale,
                              child: TaskCard(
                                elevation: elevation,
                                task: pageList.tasks[reversedIndex],
                              ),
                            );
                          },
                          // child: child,
                        );
                      }
                    },
                    onReorder: (oldIndex, newIndex) {
                      debugPrint('oldIndex: $oldIndex; lastIndex: $listWidgetsCount');
                      // order any item except for the last one
                      if (oldIndex != tasksCount) {
                        int reversedOldIndex = tasksCount - 1 - oldIndex;
                        // if you move a TaskCard to the last place put it as the penultimate (instead of the last one): since the last one (COMPLETED) is unmovable
                        int reversedNewIndex = newIndex == listWidgetsCount ? tasksCount - newIndex : tasksCount - 1 - newIndex;
                        listState.reorderList(reversedOldIndex, reversedNewIndex);
                      }
                    });
              });
        },
      ),
    );
  }
}
