import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:today/globals/constants.dart';
import 'package:today/states/app_state.dart';
import 'package:today/states/date_state.dart';
import 'package:today/states/list_state/list_state.dart';
import 'package:today/models/enums.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';

class CalendarNavContainer extends StatelessWidget {
  CalendarNavContainer({super.key});

  final listState = getIt<ListState>();
  final appState = getIt<AppState>();
  final dateState = getIt<DateState>();
  @override
  Widget build(BuildContext context) {
    return CalendarDatePicker2(
        config: CalendarDatePicker2Config(
          // cancelButton: ,
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
        onValueChanged: (dates) {
          listState.selectDateListByDate(dates.first!);
          appState.updateNavBarSelection(NavBarSelection.unselected);
        });
    ;
  }
}
