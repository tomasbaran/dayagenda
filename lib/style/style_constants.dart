import 'package:flutter/material.dart';

// ActionBar
const TextStyle actionBarLinkTextStyle = TextStyle(
  fontWeight: FontWeight.w500,
  fontSize: 16,
);

// const kBackgroundColor = Color.fromARGB(255, 228, 233, 238);
// const kThemeColor = Color(0xFFF2F6FA);
const kBackgroundColor = Color(0xFFF3F3F3); // blueGrey
const kThemeColor2 = Color(0xFFE4E9F0); // grey
const kThemeColor3 = Color.fromARGB(255, 202, 208, 215); // blueGrey
const kThemeColor4 = Color(0xFF95A2B1); // blueGrey
const kThemeColor6 = Color.fromRGBO(120, 144, 156, 1); // blueGrey
const kThemeColor7 = Colors.blueGrey; // blueGrey
const kThemeColor8 = Color.fromRGBO(84, 110, 122, 1); // blueGrey
const kThemeColor9 = Color(0xFF496370);
const kIconColor = Color(0xFF5E6678);
// Color kTodayColor = Colors.blue.shade600;
const kBlueAccentColor = Color(0xFF6589C8);

const groupColors = [
  Colors.amber,
  Colors.blue,
  Colors.brown,
  Colors.cyan,
  Colors.deepOrange,
  Colors.green,
  Colors.indigo,
  Colors.lightBlue,
  Colors.lightGreen,
  Colors.lime,
  Colors.orange,
  Colors.pink,
  Colors.purple,
];

// 496370
// dark ones
const kThemeColor10 = Color(0xFF232B34); // blueGrey
const kThemeColor11 = Color(0xFF152335); // blueGrey
const kThemeColor12 = Color(0xFF041427); // blueGrey
const kHighlightColor = kThemeColor11;

// TaskScreenAppBar
const TextStyle appBarTitleTextStyle = TextStyle(
  color: kThemeColor11,
  fontSize: 24,
  fontWeight: FontWeight.w700,
);
const TextStyle appBarSubtitleTextStyle = TextStyle(
  color: kThemeColor11,
  fontSize: 24,
  fontWeight: FontWeight.w500,
);

const TextStyle taskCardSubtitleTextStyle = TextStyle(
  color: kThemeColor7,
  fontSize: 14,
  fontWeight: FontWeight.w600,
);

// TaskCard
const double cardRadius = 12;
const double taskCardHeight = 76;

const TextStyle taskCardTitleTextStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w500,
);

// CompletedContainer
const double completedTitleHeight = 16;
const double mobileCompletedTitleBottomPadding =
    12; // COULD BE CHANGED (VARIABLE) +16 (diff btw -8 and 8 nav_container.dart line 24)=desktopCompletedTitleBottomPadding
const double desktopCompletedTitleBottomPadding = 28; // COULD BE CHANGED (VARIABLE)
const double minEmptySpaceHeight = 60;
double floatingNavBarContainerHeight = 62; // FIXED HEIGHT: bottom padding under the title: COMPLETE: 0

// TimeCard
const TextStyle timeCardTextStyle = TextStyle(
  color: Colors.white,
  fontSize: 13,
  fontWeight: FontWeight.w600,
);

// AddNewTaskSheet
const TextStyle addNewTaskSheetTitleTextStyle = TextStyle(
  color: kHighlightColor,
  fontSize: 15,
  fontWeight: FontWeight.w500,
);

const TextStyle addNewTaskSheetTaskTitleTextStyle = TextStyle(
  color: kHighlightColor,
  fontSize: 22,
  fontWeight: FontWeight.w400,
);

const TextStyle addNewTaskSheetButtonsTextStyle = TextStyle(
  color: kHighlightColor,
  fontSize: 16,
  fontWeight: FontWeight.w700,
);

const TextStyle addNewTaskSheetFieldTitleTextStyle = TextStyle(
  color: kThemeColor9,
  fontWeight: FontWeight.w500,
  fontSize: 15,
);
TextStyle addNewTaskSheetFieldHintTitleTextStyle = const TextStyle(
  color: kThemeColor3,
  fontWeight: FontWeight.w500,
  fontSize: 15,
);

const double cupertinoListTileLeadingToTitle = 28;
const double cupertinoListTileLeadingSize = 76;

// FloatingContainor
double floatingContainerWidth = 340;

// NavBar
TextStyle bottomToolbarIconTextStyle = const TextStyle(
  color: kIconColor,
  fontSize: 26,
  fontWeight: FontWeight.w400,
);

// NavBar
TextStyle navBarHeadlineTextStyle = TextStyle(
  color: kThemeColor6,
  fontSize: 20,
  fontWeight: FontWeight.w700,
);

double floatingBarRadius = 32;

// # navBarList
TextStyle navBarListTextStyle = const TextStyle(
  color: kThemeColor7,
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

// # navBarAccount
TextStyle navBarAccountTextStyle = const TextStyle(
  color: kThemeColor3,
  fontSize: 16,
  fontWeight: FontWeight.w600,
  // decoration: TextDecoration.underline,
);

// # navBarAccount
TextStyle navBarAccountHighlightedTextStyle = const TextStyle(
  color: kThemeColor2,
  fontSize: 18,
  fontWeight: FontWeight.w700,
  // decoration: TextDecoration.underline,
);

// # navBarAccount
TextStyle navBarAccountInformationTextStyle = const TextStyle(
  color: kThemeColor9,
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

TextStyle navBarAccountEmailInputLabelTextStyle = const TextStyle(
  color: kThemeColor4,
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

TextStyle navBarAccountEmailInputTextStyle = const TextStyle(
  color: kThemeColor2,
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

TextStyle navBarAccountEmailSubmitButtonTextStyle = const TextStyle(
  color: kThemeColor12,
  fontSize: 16,
  fontWeight: FontWeight.w500,
);

TextStyle navBarAccountButtonTitleTextStyle = const TextStyle(
  color: kThemeColor12,
  fontSize: 16,
  fontWeight: FontWeight.w600,
);
