import 'dart:developer';

import 'package:dayagenda/states/date_state.dart';
import 'package:dayagenda/states/list_state/list_state.dart';
import 'package:dayagenda/utils/screen_utlis.dart';
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
  final dateState = getIt<DateState>();
  final taskState = getIt<TaskState>();
  final listState = getIt<ListState>();

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
              child: ValueListenableBuilder(
                  valueListenable: task.isBeingSnoozed,
                  builder: (context, isBeingSnoozed, child) {
                    return Container(
                      decoration: BoxDecoration(
                        color: task.isCompleted
                            ? kThemeColor3
                            : isBeingSnoozed
                                ? kThemeColor3
                                : Colors.white,
                        borderRadius: BorderRadius.horizontal(
                          right: const Radius.circular(cardRadius),
                          left: task.startTime != null ? Radius.zero : const Radius.circular(cardRadius),
                        ),
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
                                  child: ValueListenableBuilder(
                                      valueListenable: dateState.isSelectedDateToday,
                                      builder: (_, isSelectedToday, __) {
                                        return Text(
                                          task.title,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: taskCardTitleTextStyle.copyWith(
                                            color: task.isCompleted
                                                ? kThemeColor10.withOpacity(task.isDefault ? 0.7 : 1)
                                                : isSelectedToday
                                                    ? kTodayColor.withOpacity(task.isDefault ? 0.7 : 1)
                                                    : Colors.black.withOpacity(task.isDefault ? 0.7 : 1),
                                            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                                          ),
                                        );
                                      }),
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

                        Visibility(
                          visible: !ScreenUtils.isMobile(context) && !task.isCompleted,
                          child: Padding(
                            padding: EdgeInsets.all(cardRadius),
                            child: Align(
                              alignment: Alignment.centerRight,
                              // This is where the listTitle will go.
                              // E.g. #Family, #Health, #Project
                              child: Icon(
                                Icons.drag_handle,
                                color: Theme.of(context).unselectedWidgetColor,
                              ),
                            ),
                          ),
                        ),
                      ]),
                    );
                  }),
            ),
          ),
          task.isCompleted
              ? const SizedBox(
                  height: 68,
                  width: 34,
                )
              : InkWell(
                  borderRadius: BorderRadius.circular(cardRadius),
                  highlightColor: kThemeColor3,
                  onTap: () async => await listState.snoozeTodoToTomorrow(task),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    height: 68,
                    width: 34,
                    child: Icon(
                      CupertinoIcons.arrow_right,
                      color: Theme.of(context).unselectedWidgetColor,
                      // color: Colors.red,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}
