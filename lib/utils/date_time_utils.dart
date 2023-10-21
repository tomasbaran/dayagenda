import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:dayagenda/models/enums.dart';

class DateTimeUtils {
  static String? formatTime(DateTime? dateTime) => dateTime == null ? null : '${dateTime.hour} : ${formatMinutes(dateTime)}';
  static String formatMinutes(DateTime dateTime) => dateTime.minute.toString().padLeft(2, '0');

  static String mixpanelNow() => DateTime.now().toLocal().toUtc().toString();
  static DayType? isSpecialDay(DateTime defaultDateTime, DateTime? checkingDateTime) {
    const Duration oneDay = Duration(hours: 24);
    if (checkingDateTime == null) {
      return null;
    } else {
      if (checkingDateTime.day == defaultDateTime.day &&
          checkingDateTime.month == defaultDateTime.month &&
          checkingDateTime.year == defaultDateTime.year) {
        return DayType.isToday;
      } else if (checkingDateTime.subtract(oneDay).day == defaultDateTime.day &&
          checkingDateTime.subtract(oneDay).month == defaultDateTime.month &&
          checkingDateTime.subtract(oneDay).year == defaultDateTime.year) {
        return DayType.isTomorrow;
      } else if (checkingDateTime.add(oneDay).day == defaultDateTime.day &&
          checkingDateTime.add(oneDay).month == defaultDateTime.month &&
          checkingDateTime.add(oneDay).year == defaultDateTime.year) {
        return DayType.isYesterday;
      } else {
        return DayType.isNoSpecial;
      }
    }
  }

  static String specialDateTimeString(DateTime dateTime) {
    switch (isSpecialDay(DateTime.now(), dateTime)) {
      case DayType.isToday:
        return 'Today';
      case DayType.isYesterday:
        return 'Yesterday';
      case DayType.isTomorrow:
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

  static DateTime? convertTimestampToDateTime(Timestamp? timestamp) =>
      timestamp == null ? null : DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch);
  static Timestamp? convertDateTimeToTimestamp(DateTime? dateTime) =>
      dateTime == null ? null : Timestamp.fromMillisecondsSinceEpoch(dateTime.millisecondsSinceEpoch);
}
