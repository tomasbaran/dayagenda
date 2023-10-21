import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:dayagenda/states/task_state.dart';
import 'package:dayagenda/models/my_task.dart';
import 'package:dayagenda/services/service_locator.dart';
import 'package:dayagenda/style/style_constants.dart';
import 'package:dayagenda/widgets/task_detail_sheet.dart';
import 'package:dayagenda/widgets/time_card.dart';

class TaskCard extends StatelessWidget {
  final double elevation;
  final MyTask task;
  TaskCard({
    required this.task,
    super.key,
    this.elevation = 0,
  });

  final taskState = getIt<TaskState>();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log('open edit sheet [${task.title}]');
        showCupertinoModalBottomSheet(
          context: context,
          builder: (context) => Scaffold(
            body: TaskDetailSheet.updateTask(task),
          ),
        );
      },
      child: Card(
        elevation: elevation,
        color: task.isCompleted ? kThemeColor3 : null,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
        child: Row(
          children: [
            TimeCard(
              taskStartTime: task.startTime,
              taskEndTime: task.endTime,
            ),
            Expanded(
              child: SizedBox(
                height: 68,
                child: Stack(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(cardRadius, cardRadius, 36, cardRadius),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
                          Checkbox(
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
                            value: task.isCompleted,
                            onChanged: (newValue) {
                              taskState.toggleTaskCompleted(task);
                            },
                          ),
                          Expanded(
                            child: Text(
                              task.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: taskCardTitleTextStyle.copyWith(
                                color: task.isCompleted ? kThemeColor10 : null,
                                decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Align(
                  //   alignment: Alignment.topLeft,
                  //   child: ,
                  // ),
                  const Padding(
                    padding: EdgeInsets.all(cardRadius),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      // This is where the listTitle will go.
                      // E.g. #Family, #Health, #Project
                      // child: Text(
                      //   task.listTitle ?? '',
                      // ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
