import 'package:flutter/material.dart';
import 'package:today/managers/list_manager.dart';
import 'package:today/services/service_locator.dart';
import 'package:today/style/style_constants.dart';

class AppManager {
  double screenHeight = 0;
  EdgeInsets safeArea = EdgeInsets.zero;

  final listManager = getIt<ListManager>();

  getScreenMeasurments(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    safeArea = MediaQuery.of(context).padding;
  }

  double get emptySpaceHeight =>
      screenHeight -
      safeArea.top - //iOS status bar
      AppBar().preferredSize.height - //appBar's height
      (listManager.selectedList.value.tasks.length * taskCardHeight) -
      completedTitleHeight -
      completedTitleBottomPadding -
      floatingBottomSafeArea;

  double get floatingBottomSafeArea => safeArea.bottom + floatingNavBarContainerHeight + 4;
}
