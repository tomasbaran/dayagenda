import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show defaultTargetPlatform;

class DialogUtils {
  static void showPlatformAlertDialog({
    required BuildContext context,
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                ),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
              ),
              CupertinoDialogAction(
                child: Text('Delete'),
                onPressed: onConfirm,
                isDestructiveAction: true,
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                },
              ),
              TextButton(
                child: Text(
                  'Delete',
                  style: TextStyle(backgroundColor: Colors.red),
                ),
                onPressed: onConfirm,
              ),
            ],
          );
        },
      );
    }
  }

  // This function displays a CupertinoModalPopup with a reasonable fixed height
// which hosts CupertinoDatePicker.
  static void showCupertinoTimePicker({
    required BuildContext context,
    required Function(DateTime) onDateTimeChanged,
    DateTime? defaultTime,
  }) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system
        // navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: CupertinoDatePicker(
            minuteInterval: 5,
            // .subtract(Duration(minutes: DateTime.now().minute % 5)) is bugfixing cases when DateTime.now() is not divisible by 5
            initialDateTime: defaultTime ?? DateTime.now().subtract(Duration(minutes: DateTime.now().minute % 5)),
            mode: CupertinoDatePickerMode.time,
            use24hFormat: true,
            onDateTimeChanged: (DateTime newTime) => onDateTimeChanged(newTime),
          ),
        ),
      ),
    );
  }
}
