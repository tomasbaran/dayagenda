import 'package:flutter/material.dart';
import 'package:today/globals/constants.dart';
import 'package:today/managers/list_manager.dart';
import 'package:today/models/enums.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/utils/date_time_utils.dart';

class DateManager {
  DateTime _selectedDate = DateTime.now();
  final isSelectedDateToday = ValueNotifier<bool>(true);

  DateTime get selectedDate => _selectedDate;

  updateSelectedDate(DateTime newDateTime) {
    _selectedDate = newDateTime;
    checkIfSelectedDateIsToday();
  }

  checkIfSelectedDateIsToday() {
    DateTimeUtils.isSpecialDay(DateTime.now(), _selectedDate) == MyDate.isToday
        ? isSelectedDateToday.value = true
        : isSelectedDateToday.value = false;
  }

  final datePageController = PageController(initialPage: todayIndex, viewportFraction: 0.95);
}
