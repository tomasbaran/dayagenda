import 'dart:developer';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:today/screens/tasks_screen/tasks_screen_manager.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';
import 'package:today/utils/date_time_utils.dart';
import 'package:today/widgets/task_time_tile.dart';
import 'package:today/utils/dialog_utlis.dart';

enum SheetType {
  newTask,
  updateTask,
}

class TaskDetailSheet extends StatefulWidget {
  final SheetType sheetType;
  // Named constructor
  const TaskDetailSheet.newTask({super.key}) : sheetType = SheetType.newTask;
  const TaskDetailSheet.updateTask({super.key}) : sheetType = SheetType.updateTask;

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  final widgetManager = getIt<TasksScreenManager>();
  String? taskTitle;
  DateTime? startTime;
  DateTime? endTime;
  late DateTime originalDate;

  @override
  void initState() {
    originalDate = widgetManager.selectedDate;
    taskTitle = widgetManager.selectedTask?.title;
    startTime = widgetManager.selectedTask?.startTime;
    endTime = widgetManager.selectedTask?.endTime;
    super.initState();
  }

  @override
  void dispose() {
    widgetManager.unselectTask();
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
          TextButton(
            child: Text(
              widget.sheetType == SheetType.newTask ? 'Add' : 'Update',
              style: addNewTaskSheetButtonsTextStyle,
            ),
            onPressed: () {
              widget.sheetType == SheetType.newTask
                  ? widgetManager.addTaskToDateList(
                      title: taskTitle,
                      startTime: startTime,
                      endTime: endTime,
                    )
                  : widgetManager.updateTask(
                      originalDate: originalDate,
                      newTitle: taskTitle,
                      newStartTime: startTime,
                      newEndTime: endTime,
                    );
              Navigator.pop(context);
            },
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
                  controller: TextEditingController.fromValue(TextEditingValue(text: taskTitle ?? '')),
                  style: addNewTaskSheetTaskTitleTextStyle,
                  maxLines: 2,
                  onChanged: (text) => taskTitle = text,
                  autofocus: true,
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
                  title: 'Starts',
                  icon: Icons.access_time,
                  value: startTime == null ? null : DateTimeUtils.formatTime(startTime!),
                ),
                onTap: () => DialogUtils.showCupertinoTimePicker(
                  context: context,
                  defaultTime: startTime,
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() => startTime = newTime);
                  },
                ),
              ),
              GestureDetector(
                child: TaskTimeTile(
                  title: 'Ends',
                  icon: Icons.access_time_filled,
                  value: endTime == null ? null : DateTimeUtils.formatTime(endTime!),
                ),
                onTap: () => DialogUtils.showCupertinoTimePicker(
                  context: context,
                  onDateTimeChanged: (DateTime newTime) {
                    setState(() => endTime = newTime);
                  },
                  defaultTime: endTime ?? startTime,
                ),
              ),
              GestureDetector(
                child: ValueListenableBuilder(
                    valueListenable: widgetManager.selectedList,
                    builder: (context, selectedList, child) {
                      return TaskTimeTile(
                        title: 'Date',
                        icon: CupertinoIcons.calendar,
                        value: DateFormat.yMMMMd('en_US').format(selectedList.date ?? widgetManager.selectedDate),
                      );
                    }),
                onTap: () async {
                  final calendarValues = await showCalendarDatePicker2Dialog(
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
                    value: [widgetManager.selectedDate],
                  );
                  if (calendarValues != null) {
                    widgetManager.updateSelectedDate(calendarValues.first!);
                  }
                },
              ),
            ],
          ),
          GestureDetector(
            onTap: () {
              DialogUtils.showPlatformAlertDialog(
                context: context,
                title: 'Delete Task',
                message: 'Are you sure you want to delete this task?',
                onConfirm: () {
                  widgetManager.removeSelectedTaskByDate(date: originalDate);
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
