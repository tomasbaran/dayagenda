import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:today/models/my_list.dart';
import 'package:today/models/my_task.dart';
import 'package:today/managers/list_manager.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';
import 'package:today/utils/date_time_utils.dart';
import 'package:today/managers/task_manager.dart';
import 'package:today/widgets/task_time_tile.dart';
import 'package:today/utils/screen_utlis.dart';

enum SheetType {
  newTask,
  updateTask,
}

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
  final taskManager = getIt<TaskManager>();
  final listManager = getIt<ListManager>();
  late MyList originalList;

  @override
  void initState() {
    super.initState();
    taskManager.selectTask = widget.task;
    originalList = listManager.selectedList.value;
  }

  @override
  void dispose() {
    taskManager.unselectTask();
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
            visible: !taskManager.selectedTask.value.isCompleted,
            child: TextButton(
              child: Text(
                widget.sheetType == SheetType.newTask ? 'Add' : 'Update',
                style: addNewTaskSheetButtonsTextStyle,
              ),
              onPressed: () async {
                widget.sheetType == SheetType.newTask
                    ? await listManager.addTaskToDateList(taskManager.selectedTask.value)
                    : await listManager.updateListByTask(
                        originalList: originalList,
                        updatedTask: taskManager.selectedTask.value,
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
                  controller: TextEditingController.fromValue(TextEditingValue(text: taskManager.selectedTask.value.title)),
                  style: addNewTaskSheetTaskTitleTextStyle,
                  maxLines: 2,
                  onChanged: (text) => taskManager.updateTitle(text),
                  autofocus: taskManager.selectedTask.value.isCompleted ? false : true,
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
                  disabled: taskManager.selectedTask.value.isCompleted,
                  title: 'Starts',
                  icon: Icons.access_time,
                  value: DateTimeUtils.formatTime(taskManager.selectedTask.value.startTime),
                ),
                onTap: () => taskManager.selectedTask.value.isCompleted
                    ? null
                    : ScreenUtils.showCupertinoTimePicker(
                        context: context,
                        defaultTime: taskManager.selectedTask.value.startTime,
                        onDateTimeChanged: (DateTime newTime) {
                          setState(() => taskManager.updateStartTime(listManager.selectedDate, newTime.hour, newTime.minute));
                        },
                      ),
              ),
              GestureDetector(
                child: TaskTimeTile(
                  disabled: taskManager.selectedTask.value.isCompleted,
                  title: 'Ends',
                  icon: Icons.access_time_filled,
                  value: DateTimeUtils.formatTime(taskManager.selectedTask.value.endTime),
                ),
                onTap: () => taskManager.selectedTask.value.isCompleted
                    ? null
                    : ScreenUtils.showCupertinoTimePicker(
                        context: context,
                        onDateTimeChanged: (DateTime newTime) {
                          setState(() => taskManager.updateEndTime(listManager.selectedDate, newTime.hour, newTime.minute));
                        },
                        defaultTime: taskManager.selectedTask.value.endTime ?? taskManager.selectedTask.value.startTime,
                      ),
              ),
              GestureDetector(
                child: ValueListenableBuilder(
                    valueListenable: listManager.selectedList,
                    builder: (context, selectedList, child) {
                      return TaskTimeTile(
                        disabled: taskManager.selectedTask.value.isCompleted,
                        title: 'Date',
                        icon: CupertinoIcons.calendar,
                        value: DateFormat.yMMMMd('en_US').format(selectedList.date ?? listManager.selectedDate),
                      );
                    }),
                onTap: () async {
                  final calendarValues = taskManager.selectedTask.value.isCompleted
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
                          value: [listManager.selectedDate],
                        );
                  if (calendarValues != null) {
                    listManager.updateSelectedDate(calendarValues.first!);
                    taskManager.updateStartEndTimeToSelectedDate();
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
                  listManager.removeTaskFromList(taskManager.selectedTask.value, listManager.selectedList.value);
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
