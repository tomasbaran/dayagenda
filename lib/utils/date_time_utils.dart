import 'package:intl/intl.dart';

enum MyDate {
  isToday,
  isTomorrow,
  isYesterday,
  isAnotherDay,
}

class DateTimeUtils {
  static String? formatTime(DateTime? dateTime) => dateTime == null ? null : '${dateTime.hour} : ${formatMinutes(dateTime)}';
  static String formatMinutes(DateTime dateTime) => dateTime.minute.toString().padLeft(2, '0');

  static MyDate? isSpecialDay(DateTime defaultDateTime, DateTime? checkingDateTime) {
    const Duration oneDay = Duration(hours: 24);
    if (checkingDateTime == null) {
      return null;
    } else {
      if (checkingDateTime.day == defaultDateTime.day &&
          checkingDateTime.month == defaultDateTime.month &&
          checkingDateTime.year == defaultDateTime.year) {
        return MyDate.isToday;
      } else if (checkingDateTime.subtract(oneDay).day == defaultDateTime.day &&
          checkingDateTime.subtract(oneDay).month == defaultDateTime.month &&
          checkingDateTime.subtract(oneDay).year == defaultDateTime.year) {
        return MyDate.isTomorrow;
      } else if (checkingDateTime.add(oneDay).day == defaultDateTime.day &&
          checkingDateTime.add(oneDay).month == defaultDateTime.month &&
          checkingDateTime.add(oneDay).year == defaultDateTime.year) {
        return MyDate.isYesterday;
      } else {
        return MyDate.isAnotherDay;
      }
    }
  }

  static String niceDateTimeString(DateTime dateTime) {
    switch (isSpecialDay(DateTime.now(), dateTime)) {
      case MyDate.isToday:
        return 'Today';
      case MyDate.isYesterday:
        return 'Yesterday';
      case MyDate.isTomorrow:
        return 'Tomorrow';
      default:
        return DateFormat('EEEE').format(dateTime);
    }
  }

  static DateTime resetTimeToZero(DateTime dateTime) => dateTime.subtract(Duration(
        hours: dateTime.hour,
        minutes: dateTime.minute,
        seconds: dateTime.second,
        microseconds: dateTime.microsecond,
        milliseconds: dateTime.millisecond,
      ));

  static DateTime mixDateAndTime({required DateTime date, required int hours, required int minutes}) {
    // Reset hours,minutes,seconds to 00:00:00
    DateTime resetTime = resetTimeToZero(date);
    return resetTime.add(Duration(hours: hours, minutes: minutes));
  }
}
