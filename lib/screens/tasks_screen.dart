import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:today/states/app_state.dart';
import 'package:today/states/date_state.dart';
import 'package:today/states/list_state/list_state.dart';
import 'package:today/models/enums.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';
import 'package:today/utils/date_time_utils.dart';
import 'package:today/widgets/tasks_container.dart';
import 'package:today/widgets/nav_container.dart';

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
    listState.listenToDateList();
  }

  @override
  void dispose() {
    listState.disposeSubscription();
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
            valueListenable: dateState.selectedDate,
            builder: ((_, selectedDate, __) => Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      DateTimeUtils.specialDateTimeString(selectedDate),
                      style: appBarTitleTextStyle,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      DateFormat.MMMMd('en_US').format(selectedDate),
                      style: appBarSubtitleTextStyle,
                    ),
                  ],
                )),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: NavContainer(),
        body: TasksContainer(),
      ),
    );
  }
}
