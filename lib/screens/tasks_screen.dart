import 'package:dayagenda/utils/screen_utlis.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/states/date_state.dart';
import 'package:dayagenda/states/list_state/list_state.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/services/service_locator.dart';
import 'package:dayagenda/style/style_constants.dart';
import 'package:dayagenda/utils/date_time_utils.dart';
import 'package:dayagenda/widgets/tasks_container.dart';
import 'package:dayagenda/widgets/nav_container.dart';
import 'package:universal_platform/universal_platform.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final listState = getIt<ListState>();
  final appState = getIt<AppState>();
  final dateState = getIt<DateState>();
  @override
  void initState() {
    super.initState();
    listState.selectDateList();
    listState.streamUserIdLists();
  }

  @override
  void dispose() {
    listState.disposeSelectedListSubscription();
    listState.disposeStreamUserIdLists();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appState.getScreenMeasurments(context);
    return GestureDetector(
      onTap: () => appState.updateNavBarSelection(NavBarSelection.unselected),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: kBackgroundColor,
          shadowColor: Colors.transparent,
          title: ValueListenableBuilder(
              valueListenable: dateState.isSelectedDateToday,
              builder: (_, isSelectedToday, __) {
                return ValueListenableBuilder(
                  valueListenable: dateState.selectedDate,
                  builder: ((_, selectedDate, __) => Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            DateTimeUtils.specialDateTimeString(selectedDate),
                            style: appBarTitleTextStyle.copyWith(color: isSelectedToday ? kTodayColor : null),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat.MMMMd('en_US').format(selectedDate),
                            style: appBarSubtitleTextStyle.copyWith(color: isSelectedToday ? kTodayColor : null),
                          ),
                        ],
                      )),
                );
              }),
        ),
        floatingActionButtonLocation: (UniversalPlatform.isAndroid || UniversalPlatform.isIOS)
            ? FloatingActionButtonLocation.centerDocked
            : FloatingActionButtonLocation.centerFloat,
        floatingActionButton: NavContainer(),
        body: TasksContainer(),
      ),
    );
  }
}
