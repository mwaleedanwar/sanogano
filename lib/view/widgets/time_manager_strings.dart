import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:get/get_utils/src/extensions/num_extensions.dart';

String getTime(DateTime time) {
  if (time.difference(DateTime.now()).inMinutes.abs() < 1)
    return time.difference(DateTime.now()).inSeconds.abs().toString() + "s";
  if (time.difference(DateTime.now()).inMinutes.abs() < 60)
    return time.difference(DateTime.now()).inMinutes.abs().toString() + "m";

  if (time.difference(DateTime.now()).inHours.abs() < 23)
    return time.difference(DateTime.now()).inHours.abs().toString() + "h";

  if (time.isBefore(currentYear)) return DateFormat.yMMMd().format(time);
  // if (time.difference(DateTime.now()).inMinutes.abs() > 60)
  //   return (time.difference(DateTime.now()).inMinutes.abs() / 60).toString() +
  //       "h";
  if (time.isBefore(dayBeforeYesterday)) return DateFormat.MMMMd().format(time);
  if (time.isAfter(dayBeforeYesterday) && time.isBefore(previousDay))
    return "Yesterday";

  if (time.isAfter(previousDay))
    return timeago.format(time, locale: 'en_short');

  return timeago.format(time, locale: 'en_short');
}

String getTimeForNotifications(DateTime time) {
  if (time.difference(DateTime.now()).inMinutes.abs() < 1)
    return time.difference(DateTime.now()).inSeconds.abs().toString() + "s";
  if (time.difference(DateTime.now()).inMinutes.abs() < 60)
    return time.difference(DateTime.now()).inMinutes.abs().toString() + "m";
  if (time.difference(DateTime.now()).inMinutes.abs() < 120)
    return time.difference(DateTime.now()).inHours.abs().toString() + "h";
  if (time.difference(DateTime.now()).inHours.abs() < 23)
    return time.difference(DateTime.now()).inHours.abs().toString() + "h";
  if (time.isBefore(currentYear)) return DateFormat.yMMMd().format(time);
  if (time.isBefore(dayBeforeYesterday)) return DateFormat.MMMd().format(time);
  if (time.isAfter(dayBeforeYesterday) && time.isBefore(previousDay))
    return "Yesterday";

  if (time.isAfter(previousDay)) return timeago.format(time, locale: 'en');

  return timeago.format(time, locale: 'en');
}

String getTimeForNotificationsCustomizedUnder12Weeks(DateTime time) {
  if (time.isBefore(twelveWeekBefore)) {
    return "";
  } else {
    if (time.difference(DateTime.now()).inMinutes.abs() < 1)
      return time.difference(DateTime.now()).inSeconds.abs().toString() + "s";
    if (time.difference(DateTime.now()).inMinutes.abs() < 60)
      return time.difference(DateTime.now()).inMinutes.abs().toString() + "m";
    if (time.difference(DateTime.now()).inMinutes.abs() < 120)
      return time.difference(DateTime.now()).inHours.abs().toString() + "h";
    if (time.difference(DateTime.now()).inHours.abs() < 23)
      return time.difference(DateTime.now()).inHours.abs().toString() + "h";
    if (time.isBefore(currentYear)) return DateFormat.yMMMd().format(time);
    if (time.isBefore(previousDay)) {
      return time.difference(DateTime.now()).inDays.abs() > 6
          ? ((time.difference(DateTime.now()).inDays.abs() / 7).truncate())
                  .toString() +
              "w"
          : time.difference(DateTime.now()).inDays.abs().toString() + "d";
    }
    // if (time.isBefore(dayBeforeYesterday))
    //   return DateFormat.MMMd().format(time);
    if (time.isAfter(dayBeforeYesterday) && time.isBefore(previousDay))
      return "1d";

    if (time.isAfter(previousDay)) return timeago.format(time, locale: 'en');

    return timeago.format(time, locale: 'en');
  }
}

String getTimeForMessages(DateTime time) {
  // if (time.difference(DateTime.now()).inMinutes.abs() < 1)
  //   return time.difference(DateTime.now()).inSeconds.abs().toString() + "s";
  if (time.isBefore(currentYear))
    return DateFormat.yMMMd().add_jm().format(time);
  if (time.isBefore(dayBeforeYesterday))
    return DateFormat.MMMMd().add_jm().format(time);
  if (time.isAfter(dayBeforeYesterday) && time.isBefore(previousDay))
    return "Yesterday ${DateFormat.jm().format(time)}";

  if (time.isAfter(previousDay)) return DateFormat.jm().format(time);

  return timeago.format(time, locale: 'en_short');
}

DateTime get previousDay => DateTime.now().subtract(1.days);
DateTime get twelveWeekBefore => DateTime.now().subtract(84.days);
DateTime get dayBeforeYesterday => DateTime.now().subtract(2.days);
DateTime get currentYear => DateTime.now().subtract(365.days);
