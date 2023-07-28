import 'package:flutter/material.dart';
import 'package:today/states/app_state.dart';
import 'package:today/states/list_state/list_state.dart';
import 'package:today/models/enums.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';
import 'package:today/widgets/calendar_nav_container.dart';
import 'package:today/widgets/nav_bar.dart';
import 'package:today/widgets/lists_nav_container.dart';
import 'package:today/widgets/account_nav_container.dart';

class NavContainer extends StatelessWidget {
  NavContainer({
    super.key,
  });

  final listState = getIt<ListState>();
  final appState = getIt<AppState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => appState.updateNavBarSelection(NavBarSelection.unselected),
      child: Material(
        borderRadius: BorderRadius.all(Radius.circular(floatingBarRadius)),
        elevation: 10,
        child: Container(
          // height: 400,
          width: floatingContainerWidth,
          decoration: BoxDecoration(
            color: kThemeColor11,
            borderRadius: BorderRadius.all(Radius.circular(floatingBarRadius)),
          ),
          child: ValueListenableBuilder(
            valueListenable: appState.navBar,
            builder: (context, navBarSelection, child) {
              switch (navBarSelection) {
                case NavBarSelection.account:
                  return const AccountNavContainer();
                case NavBarSelection.list:
                  return const ListsNavContainer();
                case NavBarSelection.calendar:
                  return CalendarNavContainer();
                default:
                  return NavBar();
              }
            },
          ),
        ),
      ),
    );
  }
}
