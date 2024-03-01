import 'package:dayagenda/features/group/presentation/manager/nav_bar_groups_manager.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/states/date_state.dart';
import 'package:dayagenda/states/list_state/list_state.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/style/style_constants.dart';
import 'package:dayagenda/widgets/task_detail_sheet.dart';

class NavBar extends StatelessWidget {
  NavBar({
    super.key,
  });

  final manager = locate<NavBarGroupsManager>();
  final listState = locate<ListState>();
  final appState = locate<AppState>();
  final dateState = locate<DateState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            // Flutter BUG: https://github.com/flutter/flutter/issues/128530
            // onTap: () => widgetManager.pageController.animateToPage(todayIndex, duration: Duration(milliseconds: 300), curve: Curves.easeIn),
            onTap: () => listState.selectDateListByDate(DateTime.now()),
            behavior: HitTestBehavior.translucent,
            child: Transform.translate(
              // angle: 0.18 * 3.1415926535897932, // Rotate 45 degrees (0.25 * 2 * pi)
              // angle: 0 * 3.1415926535897932, // Rotate 45 degrees (0.25 * 2 * pi)
              offset: Offset(0, 0),
              child: ValueListenableBuilder(
                  valueListenable: dateState.isSelectedDateToday,
                  builder: (_, isSelectedToday, __) {
                    // return CustomIcon(
                    //   imagePath: /* isSelectedToday ? 'assets/icons/hummingbird-filled.png' :  */ 'assets/icons/hummingbird-outlined.png',
                    //   size: 30,
                    //   color: isSelectedToday ? kTodayColor : kIconColor,
                    // );
                    return Icon(
                      // Icons.public,

                      // Icons.watch_later_outlined,
                      // Icons.history_toggle_off,
                      // Icons.rotate_left_outlined,
                      // isSelectedToday ? CupertinoIcons.clock_fill : CupertinoIcons.clock,
                      // Icons.history,

                      Icons.description_outlined,
                      // isSelectedToday ? Icons.description : Icons.description_outlined,
                      // isSelectedToday ? CupertinoIcons.doc_text_fill : CupertinoIcons.doc_text,
                      // CupertinoIcons.doc_plaintext,
                      // Icons.insert_drive_file_outlined,

                      // isSelectedToday ? CupertinoIcons.sunrise_fill : CupertinoIcons.sunrise,
                      // isSelectedToday ? Icons.wb_sunny : Icons.wb_sunny_outlined,
                      // isSelectedToday ? CupertinoIcons.sun_max_fill : CupertinoIcons.sun_max,
                      // isSelectedToday ? CupertinoIcons.sun_haze_fill : CupertinoIcons.sun_haze,

                      // size: 28,
                      size: 31,
                      color: isSelectedToday ? Colors.white : kIconColor,
                    );
                  }),
            ),
          ),
          GestureDetector(
            onTap: () => appState.updateNavBarSelection(NavBarSelection.calendar),
            behavior: HitTestBehavior.translucent,
            child: const Padding(
              padding: EdgeInsets.only(bottom: 2.0),
              child: Icon(
                // CupertinoIcons.calendar,
                // Icons.calendar_month_outlined,
                Icons.event_outlined,
                color: kIconColor,
                size: 32,
              ),
            ),
          ),
          // Icon(
          //   CupertinoIcons.calendar,
          //   color: kThemeColor7,
          //   size: 30,
          // ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => showCupertinoModalBottomSheet(
              context: context,
              builder: (context) => Scaffold(
                body: TaskDetailSheet.newTask(),
              ),
            ),
            child: Container(
              height: 32,
              width: 32,
              decoration: BoxDecoration(
                // color: kBackgroundColor,
                color: kIconColor,
                // border: Border.all(
                //   width: 2.3,
                //   // color: kBackgroundColor,
                //   color: kIconColor,
                // ),
                borderRadius: const BorderRadius.all(Radius.circular(10)),
              ),
              child: const Center(
                child: Icon(
                  Icons.add_rounded,
                  weight: 30,
                  size: 32,
                  // color: kIconColor,
                  color: kThemeColor11,
                ),
              ),
            ),
          ),

          // Hamburger icon
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            // onTap: () => appState.updateNavBarSelection(NavBarSelection.list),
            // onTap: () => manager.tapGroupIcon(),
            // onTap: () => manager.addGroup(),
            // onTap: () =>
            // manager.addEmployeesToDb(
            //   group: Group(name: 'My Group', id: '2hpJ7RCzrB4VuAYk6yfp', ownerUid: 'dMcYZrKOdWQYWr7eIaJtrpRj2DE2'),
            //   employees: [
            //     Employee(firstName: 'Anna', secondName: 'secondName', phone: '9992438818'),
            //     Employee(firstName: 'Tomas', phone: '9991759427'),
            //   ],
            // ),
            onTap: () => appState.updateNavBarSelection(appState.isSignedIn.value ? NavBarSelection.groups : NavBarSelection.account),

            // child: Text(
            //   '&',
            //   style: bottomToolbarIconTextStyle,
            // ),
            child: Icon(
              // Icons.flash_auto,
              // CupertinoIcons.line_horizontal_3_decrease,
              // Icons.notes_rounded,
              // Icons.filter_list_rounded,
              // CupertinoIcons.person,
              Icons.group_outlined,

              color: kIconColor,
              size: 30,
            ),
          ),
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => appState.updateNavBarSelection(NavBarSelection.account),
            child:
                // Icons.messenger_outline_sharp,
                // CupertinoIcons.bubble_left,
                Icon(
              Icons.person_outline,
              size: 30,
              color: kIconColor,
            ),
          ),
        ],
      ),
    );
  }
}
