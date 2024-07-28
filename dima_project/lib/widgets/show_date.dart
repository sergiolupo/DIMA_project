import 'package:dima_project/utils/date_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

class ShowDate extends StatelessWidget {
  final DateTime date;
  final DateTime time;
  const ShowDate({super.key, required this.date, required this.time});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          'assets/calendar_icon.png',
          width: 100,
          height: 100,
        ),
        Positioned(
          top: 18,
          left: 20,
          child: Text(
            DateFormat('yMMM').format(date),
            style: const TextStyle(color: CupertinoColors.white),
          ),
        ),
        Positioned(
          top: 45,
          left: 25,
          child: Text(
            '${DateFormat('EEE').format(date)} ${date.day}',
            style: const TextStyle(color: CupertinoColors.black),
          ),
        ),
        Positioned(
          top: 65,
          left: 30,
          child: Text(
            DateFormat('HH:mm').format(time),
            style: const TextStyle(color: CupertinoColors.black),
          ),
        ),
      ],
    );
  }
}
