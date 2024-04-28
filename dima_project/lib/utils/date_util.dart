import 'package:flutter/cupertino.dart';

class DateUtil {
  static String getFormattedDate(
      {required BuildContext context, required String time}) {
    final date = DateTime.fromMicrosecondsSinceEpoch(int.parse(time));
    final localizations = CupertinoLocalizations.of(context);

    int hour = date.hour;
    final String period = hour < 12
        ? localizations.anteMeridiemAbbreviation
        : localizations.postMeridiemAbbreviation;
    hour = _hourOfPeriod(hour);
    return '${_formatHour(hour)}:${_formatMinute(date.minute)} $period';
  }

  static int _hourOfPeriod(int hour) {
    if (hour == 0) {
      return 12;
    } else if (hour > 12) {
      return hour - 12;
    } else {
      return hour;
    }
  }

  static String _formatHour(int hour) {
    return hour.toString().padLeft(2, '0');
  }

  static String _formatMinute(int minute) {
    return minute.toString().padLeft(2, '0');
  }
}
