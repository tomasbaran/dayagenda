import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:today/states/date_state.dart';
import 'package:today/models/enums.dart';
import 'package:today/models/my_list.dart';
import 'package:today/models/my_task.dart';
import 'package:today/states/list_state.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';
import 'package:today/utils/date_time_utils.dart';
import 'package:today/states/task_state.dart';
import 'package:today/widgets/task_time_tile.dart';
import 'package:today/utils/screen_utlis.dart';

class TaskDetailSheet extends StatefulWidget {
  final SheetType sheetType;
  final MyTask task;
  TaskDetailSheet.newTask({super.key})
      : task = MyTask(title: ''),
        sheetType = SheetType.newTask;
  const TaskDetailSheet.updateTask(this.task, {super.key}) : sheetType = SheetType.updateTask;
  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  final taskState = getIt<TaskState>();
  final listState = getIt<ListState>();
  final dateState = getIt<DateState>();
  late MyList originalList;

  @override
  void initState() {
    super.initState();
    taskState.selectTask = widget.task;
    originalList = listState.selectedList.value;
  }

  @override
  void dispose() {
    taskState.unselectTask();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        shadowColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.cancel),
          color: kThemeColor4,
        ),
        title: Text(
          widget.sheetType == SheetType.newTask ? 'Add New Task' : 'Edit Task',
          style: addNewTaskSheetTitleTextStyle,
        ),
        actions: [
          Visibility(
            visible: !taskState.selectedTask.value.isCompleted,
            child: TextButton(
              child: Text(
                widget.sheetType == SheetType.newTask ? 'Add' : 'Update',
                style: addNewTaskSheetButtonsTextStyle,
              ),
              onPressed: () {
                widget.sheetType == SheetType.newTask
                    ? listState.addTaskToDateList(taskState.selectedTask.value)
                    : listState.updateListByTask(
                        updatedTask: taskState.selectedTask.value,
                        originalList: originalList,
                      );
                if (mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          CupertinoListSection.insetGrouped(
            children: [
              CupertinoListTile.notched(
                backgroundColor: kBackgroundColor,
                title: TextField(
                  controller: TextEditingController.fromValue(TextEditingValue(text: taskState.selectedTask.value.title)),
                  style: addNewTaskSheetTaskTitleTextStyle,
                  maxLines: 2,
                  onChanged: (text) => taskState.updateTitle(text),
                  autofocus: taskState.selectedTask.value.isCompleted ? false : true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(hintText: 'Write Task Title', border: InputBorder.none),
                ),
              ),
            ],
          ),
          CupertinoListSection.insetGrouped(
            dividerMargin: cupertinoListTileLeadingSize,
            children: [
              GestureDetector(
                child: TaskTimeTile(
                  disabled: taskState.selectedTask.value.isCompleted,
                  title: 'Starts',
                  icon: Icons.access_time,
                  value: DateTimeUtils.formatTime(taskState.selectedTask.value.startTime),
                ),
                onTap: () => taskState.selectedTask.value.isCompleted
                    ? null
                    : ScreenUtils.showCupertinoTimePicker(
                        context: context,
                        defaultTime: taskState.selectedTask.value.startTime,
                        onDateTimeChanged: (DateTime newTime) {
                          setState(() => taskState.updateStartTime(dateState.selectedDate, newTime.hour, newTime.minute));
                        },
                      ),
              ),
              GestureDetector(
                child: TaskTimeTile(
                  disabled: taskState.selectedTask.value.isCompleted,
                  title: 'Ends',
                  icon: Icons.access_time_filled,
                  value: DateTimeUtils.formatTime(taskState.selectedTask.value.endTime),
                ),
                onTap: () => taskState.selectedTask.value.isCompleted
                    ? null
                    : ScreenUtils.showCupertinoTimePicker(
                        context: context,
                        onDateTimeChanged: (DateTime newTime) {
                          setState(() => taskState.updateEndTime(dateState.selectedDate, newTime.hour, newTime.minute));
                        },
                        defaultTime: taskState.selectedTask.value.endTime ?? taskState.selectedTask.value.startTime,
                      ),
              ),
              GestureDetector(
                child: ValueListenableBuilder(
                    valueListenable: listState.selectedList,
                    builder: (context, selectedList, child) {
                      return TaskTimeTile(
                        disabled: taskState.selectedTask.value.isCompleted,
                        title: 'Date',
                        icon: CupertinoIcons.calendar,
                        value: DateFormat.yMMMMd('en_US').format(selectedList.date ?? dateState.selectedDate),
                      );
                    }),
                onTap: () async {
                  final calendarValues = taskState.selectedTask.value.isCompleted
                      ? null
                      : await showCalendarDatePicker2Dialog(
                          borderRadius: BorderRadius.all(Radius.circular(floatingBarRadius)),
                          dialogBackgroundColor: kThemeColor11,
                          dialogSize: const Size(340, 340),
                          context: context,
                          config: CalendarDatePicker2WithActionButtonsConfig(
                            okButton: Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: Text('OK',
                                  style: TextStyle(
                                    color: kBackgroundColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                  )),
                            ),
                            buttonPadding: EdgeInsets.all(16),
                            cancelButtonTextStyle: TextStyle(fontWeight: FontWeight.w500, color: kThemeColor9),
                            firstDayOfWeek: 1,
                            dayTextStyle: TextStyle(color: kThemeColor2),
                            disableModePicker: true,
                            controlsTextStyle: TextStyle(color: kThemeColor9, fontWeight: FontWeight.w800),
                            weekdayLabelTextStyle: TextStyle(color: kThemeColor9, fontWeight: FontWeight.w800),
                            selectedDayTextStyle: TextStyle(color: kThemeColor11, fontWeight: FontWeight.w700),
                            nextMonthIcon: Icon(Icons.arrow_forward_ios_rounded, size: 20, color: kThemeColor9),
                            lastMonthIcon: Icon(Icons.arrow_back_ios_rounded, size: 20, color: kThemeColor9),
                          ),
                          value: [dateState.selectedDate],
                        );
                  if (calendarValues != null) {
                    listState.selectDateListByDate(calendarValues.first!);
                    taskState.updateStartEndTimeToSelectedDate();
                  }
                },
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              ScreenUtils.showPlatformAlertDialog(
                context: context,
                title: 'Delete Task',
                message: 'Are you sure you want to delete this task?',
                onConfirm: () {
                  listState.removeTaskFromList(taskState.selectedTask.value, listState.selectedList.value);
                  Navigator.pop(context); // Close the dialog
                  Navigator.pop(context); // Pop the previous screen
                },
              );
            },
            child: CupertinoListSection.insetGrouped(
              children: [
                CupertinoListTile.notched(
                  title: Center(
                    child: Text(
                      'Delete Task',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: SizedBox(),
          ),
        ],
      ),
    );
  }
}
