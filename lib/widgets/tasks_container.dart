import 'dart:developer';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:today/models/my_list.dart';
import 'package:today/screens/tasks_screen/tasks_screen_manager.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';
import 'package:today/widgets/floating_container.dart';
import 'package:today/widgets/completed_tasks_column.dart';
import 'package:today/widgets/task_card.dart';

import '../globals/constants.dart';

class TasksContainer extends StatelessWidget {
  TasksContainer({
    Key? key,
  }) : super(key: key);

  final widgetManager = getIt<TasksScreenManager>();

  @override
  Widget build(BuildContext context) {
    final pageController = widgetManager.pageController;
    return SafeArea(
      minimum: EdgeInsets.only(bottom: widgetManager.calcFloatingBottomSafeArea()),
      child: PageView.builder(
        onPageChanged: (newPage) => widgetManager.changePage(pageController.page ?? todayIndex.toDouble(), newPage),
        controller: pageController,
        itemBuilder: (____, pageIndex) {
          return ValueListenableBuilder<MyList>(
              valueListenable: widgetManager.selectedList,
              builder: (_, pageList, __) {
                // BUG#9: starts here, for some reasons tasksCount != e.g. 3 when pageList.tasks.length=3 after toggling a task as completed
                // it most probably could be easily fixed by removing the next line and just calling 'pageList.tasks.length' instead
                // but I don't like this approach, there has to be a better way
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
                        // BUG#9: reversedIndex is one number higher from what it should be
                        return TaskCard(
                          key: Key(reversedIndex.toString()),
                          task: pageList.tasks[reversedIndex],
                        );
                      }
                    }),
                    // possible bugfix of scrollbug#2 by utilizing the below scrollController instead of using PageView's NotificationListener
                    // scrollController: ,
                    proxyDecorator: (_, taskIndex, animation) {
                      print('taskIndex: $taskIndex; lastIndex: $tasksCount');
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
                      print('oldIndex: $oldIndex; lastIndex: $listWidgetsCount');
                      // order any item except for the last one
                      if (oldIndex != tasksCount) {
                        int reversedOldIndex = tasksCount - 1 - oldIndex;
                        // if you move a TaskCard to the last place put it as the penultimate (instead of the last one): since the last one (COMPLETED) is unmovable
                        int reversedNewIndex = newIndex == listWidgetsCount ? tasksCount - newIndex : tasksCount - 1 - newIndex;
                        widgetManager.reorderList(reversedOldIndex, reversedNewIndex);
                      }
                    });
              });
        },
      ),
    );
  }
}
