import 'package:dayagenda/features/group/presentation/widgets/no_groups.dart';
import 'package:flutter/material.dart';
import 'package:dayagenda/states/app_state.dart';
import 'package:dayagenda/states/list_state/list_state.dart';
import 'package:dayagenda/models/enums.dart';
import 'package:dayagenda/core/dependencies_locator.dart';
import 'package:dayagenda/style/style_constants.dart';
import 'package:dayagenda/widgets/calendar_nav_container.dart';
import 'package:dayagenda/widgets/nav_bar.dart';
import 'package:dayagenda/widgets/lists_nav_container.dart';
import 'package:dayagenda/widgets/account_nav_container.dart';
import 'package:universal_platform/universal_platform.dart';

class NavContainer extends StatelessWidget {
  NavContainer({
    super.key,
  });

  final listState = locate<ListState>();
  final appState = locate<AppState>();

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: Offset(0, UniversalPlatform.isAndroid || UniversalPlatform.isIOS ? 8 : -8),
      child: GestureDetector(
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
                    return AccountNavContainer();
                  case NavBarSelection.list:
                    return ListsNavContainer();
                  case NavBarSelection.calendar:
                    return CalendarNavContainer();
                  case NavBarSelection.groups:
                    return NoGroups();
                  default:
                    return NavBar();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}
