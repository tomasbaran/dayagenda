import 'package:flutter/material.dart';
import 'package:today/globals/constants.dart';
import 'package:today/states/list_state.dart';
import 'package:today/models/enums.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/utils/date_time_utils.dart';

class DateManager {
  DateTime _selectedDate = DateTime.now();
  final isSelectedDateToday = ValueNotifier<bool>(true);

  DateTime get selectedDate => _selectedDate;

  selecteNewDate(DateTime newDateTime) {
    _selectedDate = newDateTime;
    isSelectedDateToday.value = checkIfSelectedDateIsToday();
  }

  bool checkIfSelectedDateIsToday() => DateTimeUtils.isSpecialDay(DateTime.now(), _selectedDate) == DayType.isToday;
}
