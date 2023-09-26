import 'package:flutter/material.dart';
import 'package:today/models/enums.dart';
import 'package:today/services/mixpanel_service.dart';
import 'package:today/utils/date_time_utils.dart';

class DateState {
  final selectedDate = ValueNotifier<DateTime>(DateTime.now());
  final isSelectedDateToday = ValueNotifier<bool>(true);

  selecteNewDate(DateTime newDateTime) {
    selectedDate.value = newDateTime;
    isSelectedDateToday.value = checkIfSelectedDateIsToday();

    if (isSelectedDateToday.value) {
      MixpanelService.mixpanel?.track('Today View');
    }
  }

  bool checkIfSelectedDateIsToday() => DateTimeUtils.isSpecialDay(DateTime.now(), selectedDate.value) == DayType.isToday;
}
