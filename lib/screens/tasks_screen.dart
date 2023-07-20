import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:today/managers/app_manager.dart';
import 'package:today/managers/list_manager.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';
import 'package:today/widgets/floating_container.dart';
import 'package:today/widgets/tasks_container.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final listManager = getIt<ListManager>();
  final appManager = getIt<AppManager>();
  @override
  void initState() {
    super.initState();
    listManager.listenToDateList();
  }

  @override
  void dispose() {
    listManager.disposeSubscription();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    appManager.getScreenMeasurments(context);
    return GestureDetector(
      onTap: () => listManager.updateNavBarSelection(NavBarSelection.unselected),
      child: Scaffold(
        appBar: AppBar(
          shadowColor: Colors.transparent,
          title: ValueListenableBuilder(
            valueListenable: listManager.selectedList,
            builder: ((_, selectedList, __) => Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      selectedList.title ?? '...',
                      style: appBarTitleTextStyle,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      selectedList.date == null ? '?' : DateFormat.MMMMd('en_US').format(selectedList.date!),
                      style: appBarSubtitleTextStyle,
                    ),
                  ],
                )),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: FloatingContainer(),
        body: TasksContainer(),
      ),
    );
  }
}
