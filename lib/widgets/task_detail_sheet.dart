import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:today/models/my_list.dart';
import 'package:today/models/my_task.dart';
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
  final MyTask task;
  TaskDetailSheet.newTask({super.key})
      : task = MyTask(title: ''),
        sheetType = SheetType.newTask;
  const TaskDetailSheet.updateTask(this.task, {super.key}) : sheetType = SheetType.updateTask;
  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  final widgetManager = getIt<TasksScreenManager>();
  late MyList originalList;

  @override
  void initState() {
    super.initState();
    widgetManager.selectTask = widget.task;
    originalList = widgetManager.selectedList.value;
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
          Visibility(
            visible: !widgetManager.selectedTask!.completed,
            child: TextButton(
              child: Text(
                widget.sheetType == SheetType.newTask ? 'Add' : 'Update',
                style: addNewTaskSheetButtonsTextStyle,
              ),
              onPressed: () async {
                widget.sheetType == SheetType.newTask
                    ? await widgetManager.addTaskToDateList(widgetManager.selectedTask!)
                    : await widgetManager.updateTask(
                        originalList: originalList,
                        updatedTask: widgetManager.selectedTask!,
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
                  controller: TextEditingController.fromValue(TextEditingValue(text: widgetManager.selectedTask?.title ?? '')),
                  style: addNewTaskSheetTaskTitleTextStyle,
                  maxLines: 2,
                  onChanged: (text) => widgetManager.selectedTask?.title = text,
                  autofocus: widgetManager.selectedTask!.completed ? false : true,
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
                  disabled: widgetManager.selectedTask!.completed,
                  title: 'Starts',
                  icon: Icons.access_time,
                  value: DateTimeUtils.formatTime(widgetManager.selectedTask!.startTime),
                ),
                onTap: () => widgetManager.selectedTask!.completed
                    ? null
                    : DialogUtils.showCupertinoTimePicker(
                        context: context,
                        defaultTime: widgetManager.selectedTask?.startTime,
                        onDateTimeChanged: (DateTime newTime) {
                          setState(() => widgetManager.selectedTask?.updateStartTime(newTime.hour, newTime.minute));
                        },
                      ),
              ),
              GestureDetector(
                child: TaskTimeTile(
                  disabled: widgetManager.selectedTask!.completed,
                  title: 'Ends',
                  icon: Icons.access_time_filled,
                  value: DateTimeUtils.formatTime(widgetManager.selectedTask!.endTime),
                ),
                onTap: () => widgetManager.selectedTask!.completed
                    ? null
                    : DialogUtils.showCupertinoTimePicker(
                        context: context,
                        onDateTimeChanged: (DateTime newTime) {
                          setState(() => widgetManager.selectedTask?.updateEndTime(newTime.hour, newTime.minute));
                        },
                        defaultTime: widgetManager.selectedTask?.endTime ?? widgetManager.selectedTask?.startTime,
                      ),
              ),
              GestureDetector(
                child: ValueListenableBuilder(
                    valueListenable: widgetManager.selectedList,
                    builder: (context, selectedList, child) {
                      return TaskTimeTile(
                        disabled: widgetManager.selectedTask!.completed,
                        title: 'Date',
                        icon: CupertinoIcons.calendar,
                        value: DateFormat.yMMMMd('en_US').format(selectedList.date ?? widgetManager.selectedDate),
                      );
                    }),
                onTap: () async {
                  final calendarValues = widgetManager.selectedTask!.completed
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
                          value: [widgetManager.selectedDate],
                        );
                  if (calendarValues != null) {
                    widgetManager.updateSelectedDate(calendarValues.first!);
                    widgetManager.updateStartEndTimeToSelectedDate();
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
                  widgetManager.removeTaskFromList(widgetManager.selectedTask!, widgetManager.selectedList.value);
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
