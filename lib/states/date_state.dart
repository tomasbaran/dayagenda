import 'package:flutter/material.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/services/mixpanel_service.dart';
import 'package:dayagenda/utils/date_time_utils.dart';

class DateState {
  final selectedDate = ValueNotifier<DateTime>(DateTimeUtils.resetTimeToZero(DateTime.now()));
  final isSelectedDateToday = ValueNotifier<bool>(true);

  selecteNewDate(DateTime newDateTime) {
    selectedDate.value = DateTimeUtils.resetTimeToZero(newDateTime);
    isSelectedDateToday.value = checkIfSelectedDateIsToday();

    if (isSelectedDateToday.value) {
      MixpanelService.mixpanel?.track('Today View');
      MixpanelService.mixpanel?.getPeople().increment('viewed_today_counter', 1);
    }
  }

  bool checkIfSelectedDateIsToday() => DateTimeUtils.isSpecialDay(DateTime.now(), selectedDate.value) == DayType.isToday;
}
