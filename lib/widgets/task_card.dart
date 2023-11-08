import 'dart:developer';

import 'package:flutter/cupertino.dart';
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
    return Card(
      elevation: elevation,
      // color: task.isCompleted ? kThemeColor3 : null,
      color: kBackgroundColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
      child: Row(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Checkbox(
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(4))),
              value: task.isCompleted,
              onChanged: (newValue) {
                taskState.toggleTaskCompleted(task);
              },
            ),
          ),
          TimeCard(
            taskStartTime: task.startTime,
            taskEndTime: task.endTime,
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                log('open edit sheet [${task.title}]');
                showCupertinoModalBottomSheet(
                  context: context,
                  builder: (context) => Scaffold(
                    body: TaskDetailSheet.updateTask(task),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: task.isCompleted ? kThemeColor3 : Colors.white,
                  borderRadius: const BorderRadius.all(Radius.circular(cardRadius)),
                ),
                height: 68,
                child: Stack(children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(cardRadius, cardRadius, 36, cardRadius),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Row(
                        children: [
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
          ),
          task.isCompleted
              ? const SizedBox()
              : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    CupertinoIcons.arrow_right,
                  ),
                ),
        ],
      ),
    );
  }
}
