import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
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
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Select New Date',
            style: navBarHeadlineTextStyle,
          ),
          const SizedBox(height: 24),
          CalendarDatePicker2(
              config: CalendarDatePicker2Config(
                // cancelButton: ,
                firstDayOfWeek: 1,
                dayTextStyle: const TextStyle(color: kThemeColor2),
                disableModePicker: true,
                controlsTextStyle: const TextStyle(color: kThemeColor9, fontWeight: FontWeight.w800),
                weekdayLabelTextStyle: const TextStyle(color: kThemeColor9, fontWeight: FontWeight.w800),
                selectedDayTextStyle: const TextStyle(color: kThemeColor11, fontWeight: FontWeight.w700),
                nextMonthIcon: const Icon(Icons.arrow_forward_ios_rounded, size: 20, color: kThemeColor9),
                lastMonthIcon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: kThemeColor9),
              ),
              value: [dateState.selectedDate.value],
              onValueChanged: (dates) {
                listState.selectDateListByDate(dates.first!);
                appState.updateNavBarSelection(NavBarSelection.unselected);
              }),
        ],
      ),
    );
  }
}
