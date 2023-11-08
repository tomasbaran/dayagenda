import 'package:dayagenda/widgets/custom_icon.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/states/date_state.dart';
import 'package:dayagenda/states/list_state/list_state.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/services/service_locator.dart';
import 'package:dayagenda/style/style_constants.dart';
import 'package:dayagenda/widgets/task_detail_sheet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NavBar extends StatelessWidget {
  NavBar({
    super.key,
  });

  final listState = getIt<ListState>();
  final appState = getIt<AppState>();
  final dateState = getIt<DateState>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          // Flutter BUG: https://github.com/flutter/flutter/issues/128530
          // onTap: () => widgetManager.pageController.animateToPage(todayIndex, duration: Duration(milliseconds: 300), curve: Curves.easeIn),
          onTap: () => listState.selectDateListByDate(DateTime.now()),
          behavior: HitTestBehavior.translucent,
          child: Padding(
            padding: const EdgeInsets.only(left: 28, top: 16, bottom: 16, right: 16),
            child: Transform.translate(
              // angle: 0.18 * 3.1415926535897932, // Rotate 45 degrees (0.25 * 2 * pi)
              // angle: 0 * 3.1415926535897932, // Rotate 45 degrees (0.25 * 2 * pi)
              offset: Offset(0, 0),
              child: ValueListenableBuilder(
                  valueListenable: dateState.isSelectedDateToday,
                  builder: (_, isSelectedToday, __) {
                    return CustomIcon(
                      imagePath: isSelectedToday ? 'assets/icons/hummingbird-filled.png' : 'assets/icons/hummingbird-outlined.png',
                      size: 30,
                      color: Colors.blue,
                    );
                    return Icon(
                      // Icons.public,

                      // Icons.watch_later_outlined,
                      // Icons.history_toggle_off,
                      // Icons.rotate_left_outlined,
                      // isSelectedToday ? CupertinoIcons.clock_fill : CupertinoIcons.clock,
                      // Icons.history,

                      // isSelectedToday ? Icons.description : Icons.description_outlined,
                      // isSelectedToday ? CupertinoIcons.doc_text_fill : CupertinoIcons.doc_text,
                      // CupertinoIcons.doc_plaintext,
                      // Icons.insert_drive_file_outlined,

                      isSelectedToday ? CupertinoIcons.sunrise_fill : CupertinoIcons.sunrise,
                      // isSelectedToday ? Icons.wb_sunny : Icons.wb_sunny_outlined,
                      // isSelectedToday ? CupertinoIcons.sun_max_fill : CupertinoIcons.sun_max,
                      // isSelectedToday ? CupertinoIcons.sun_haze_fill : CupertinoIcons.sun_haze,

                      // size: 28,
                      size: 31,
                      color: kIconColor,
                    );
                  }),
            ),
          ),
        ),
        GestureDetector(
          onTap: () => appState.updateNavBarSelection(NavBarSelection.calendar),
          behavior: HitTestBehavior.translucent,
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Padding(
              padding: EdgeInsets.only(bottom: 2),
              child: Icon(
                CupertinoIcons.calendar,
                // Icons.calendar_today_outlined,
                color: kIconColor,
                size: 28,
              ),
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                // color: kIconColor,
                border: Border.all(
                  width: 2.3,
                  color: kIconColor,
                ),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
              ),
              child: const Center(
                child: Icon(
                  Icons.add_rounded,
                  weight: 10,
                  size: 23,
                  color: kIconColor,
                  // color: kThemeColor12,
                ),
              ),
            ),
          ),
        ),

        // Hamburger icon
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => appState.updateNavBarSelection(NavBarSelection.list),
          // child: Text(
          //   '&',
          //   style: bottomToolbarIconTextStyle,
          // ),
          child: const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(
              // Icons.flash_auto,
              CupertinoIcons.line_horizontal_3_decrease,
              // Icons.notes_rounded,
              color: kIconColor,
              size: 30,
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => appState.updateNavBarSelection(NavBarSelection.account),
          child:
              // Icons.messenger_outline_sharp,
              // CupertinoIcons.bubble_left,
              const Padding(
            padding: EdgeInsets.only(right: 32, top: 16, bottom: 16, left: 16),
            child: FaIcon(
              // Icons.account_circle_outlined,
              // CupertinoIcons.person,
              FontAwesomeIcons.user,
              // FontAwesomeIcons.paperPlane,
              // FontAwesomeIcons.commentDots,
              color: kIconColor,
              // size: 22,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }
}
