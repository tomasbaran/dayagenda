import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:today/screens/tasks_screen/tasks_screen_manager.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';
import 'package:today/widgets/task_detail_sheet.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class NavBar extends StatelessWidget {
  NavBar({
    super.key,
  });

  final widgetManager = getIt<TasksScreenManager>();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          // onTap: () => widgetManager.pageController.animateToPage(todayIndex, duration: Duration(milliseconds: 300), curve: Curves.easeIn),
          onTap: () => widgetManager.updateSelectedDate(DateTime.now()),
          behavior: HitTestBehavior.translucent,
          child: Padding(
            padding: const EdgeInsets.only(left: 28, top: 16, bottom: 16, right: 16),
            child: Transform.rotate(
              angle: 0.18 * 3.1415926535897932, // Rotate 45 degrees (0.25 * 2 * pi)
              child: ValueListenableBuilder(
                  valueListenable: widgetManager.isSelectedDateToday,
                  builder: (_, isSelectedToday, __) {
                    return Icon(
                      isSelectedToday ? Icons.push_pin : Icons.push_pin_outlined,
                      size: 28,
                      color: kIconColor,
                    );
                  }),
            ),
          ),
          // child: Icon(
          // Icons.blur_circular,
          // Icons.radio_button_on_rounded,
          // Icons.view_timeline_outlined,
          // Icons.format_list_bulleted,
          // CupertinoIcons.line_horizontal_3_decrease,
          // Icons.center_focus_strong_outlined,
          // Icons.picture_in_picture,
          // Icons.public_sharp,
          // Icons.spa_outlined,

          //  Icons.push_pin_outlined,
          // Icons.notes_rounded,
          // CupertinoIcons.doc_plaintext,
          // Icons.note_outlined,
          // Icons.fullscreen_rounded,
          // Icons.wb_sunny_outlined,
          // CupertinoIcons.house,
          //   size: 28,
          //   color: kIconColor,
          // ),
        ),
        GestureDetector(
          onTap: () => widgetManager.updateNavBarSelection(NavBarSelection.calendar),
          behavior: HitTestBehavior.translucent,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Icon(
                // CupertinoIcons.calendar,
                Icons.calendar_today_outlined,
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
            builder: (context) => const Scaffold(
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
                borderRadius: BorderRadius.all(Radius.circular(8)),
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
          onTap: () => widgetManager.updateNavBarSelection(NavBarSelection.list),
          // child: Text(
          //   '&',
          //   style: bottomToolbarIconTextStyle,
          // ),
          child: Padding(
            padding: const EdgeInsets.all(16),
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
          onTap: () => widgetManager.updateNavBarSelection(NavBarSelection.list),
          child:
              // Icons.messenger_outline_sharp,
              // CupertinoIcons.bubble_left,
              Padding(
            padding: const EdgeInsets.only(right: 32, top: 16, bottom: 16, left: 16),
            child: FaIcon(
              FontAwesomeIcons.paperPlane,
              // FontAwesomeIcons.commentDots,
              color: kIconColor,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }
}
