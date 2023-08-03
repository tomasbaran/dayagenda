import 'package:flutter/material.dart';
import 'package:today/states/date_state.dart';
import 'package:today/models/enums.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';
import 'package:intl/intl.dart';
import 'package:today/utils/date_time_utils.dart';

class TimeCard extends StatelessWidget {
  final DateTime? taskStartTime;
  final DateTime? taskEndTime;
  TimeCard({
    super.key,
    this.taskEndTime,
    this.taskStartTime,
  });

  final dateState = getIt<DateState>();

  @override
  Widget build(BuildContext context) {
    String startTimeString = taskStartTime == null ? '' : '${taskStartTime!.hour}:${taskStartTime!.minute.toString().padLeft(2, '0')}';
    String endTimeString = taskEndTime == null ? '' : '${taskEndTime!.hour}:${taskEndTime!.minute.toString().padLeft(2, '0')}';
    String dateString = taskStartTime == null ? '' : '${taskStartTime!.day} ${DateFormat('MMM').format(taskStartTime!)}';

    return Visibility(
      visible: taskStartTime != null,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.horizontal(left: Radius.circular(cardRadius)),
          color: kHighlightColor,
        ),
        height: 68,
        width: 64,
        child: Padding(
          padding: EdgeInsets.all(DateTimeUtils.isSpecialDay(dateState.selectedDate, taskStartTime) == DayType.isToday ? 6 : 2),
          child: Column(
            mainAxisAlignment: taskEndTime == null ? MainAxisAlignment.center : MainAxisAlignment.spaceEvenly,
            children: [
              Text(startTimeString, style: timeCardTextStyle),
              Visibility(
                visible: taskEndTime != null,
                child: Text(
                  DateTimeUtils.isSpecialDay(dateState.selectedDate, taskStartTime) == DayType.isToday ? '' : dateString,
                  style: timeCardTextStyle,
                ),
              ),
              Visibility(
                visible: taskEndTime != null,
                child: Text(endTimeString, style: timeCardTextStyle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
