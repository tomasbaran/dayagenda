import 'package:flutter/material.dart';
import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/states/date_state.dart';
import 'package:dayagenda/states/list_state/list_state.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/services/service_locator.dart';
import 'package:dayagenda/style/style_constants.dart';

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
                  firstDayOfWeek: 0,
                  dayTextStyle: const TextStyle(color: kThemeColor2),
                  disableModePicker: true,
                  controlsTextStyle: const TextStyle(color: kThemeColor9, fontWeight: FontWeight.w800),
                  weekdayLabelTextStyle: const TextStyle(color: kThemeColor9, fontWeight: FontWeight.w800),
                  selectedDayTextStyle: const TextStyle(color: kThemeColor11, fontWeight: FontWeight.w700),
                  nextMonthIcon: const Icon(Icons.arrow_forward_ios_rounded, size: 20, color: kThemeColor9),
                  lastMonthIcon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: kThemeColor9),
                  dayBuilder: ({
                    required date,
                    textStyle,
                    decoration,
                    isSelected,
                    isDisabled,
                    isToday,
                  }) {
                    Widget? dayWidget;
                    if (date.day % 3 == 0 && date.day % 9 != 0) {
                      dayWidget = Container(
                        decoration: decoration,
                        child: Center(
                          child: Stack(
                            alignment: AlignmentDirectional.center,
                            children: [
                              Text(
                                MaterialLocalizations.of(context).formatDecimal(date.day),
                                style: textStyle,
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 27.5),
                                child: Container(
                                  height: 4,
                                  width: 4,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: isSelected == true ? Colors.white : Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return dayWidget;
                  }),
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
