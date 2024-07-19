import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class DatePicker extends StatelessWidget {
  final DateTime initialDateTime;
  final ValueChanged<DateTime> onDateTimeChanged;

  const DatePicker({
    super.key,
    required this.initialDateTime,
    required this.onDateTimeChanged,
  });

  /*@override
  Widget build(BuildContext context) {
    return CupertinoButton(
      color: CupertinoColors.activeBlue,
      child: Text('Pick a date'),
      onPressed: () => showSheet(
        context,
        initialDateTime: initialDateTime,
        onDateTimeChanged: onDateTimeChanged,
      ),
    );
  }*/
  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(30),
      child: Icon(
        FontAwesomeIcons.calendar,
        color: CupertinoTheme.of(context).primaryColor,
      ),
      onPressed: () => showSheet(
        context,
        initialDateTime: initialDateTime,
        onDateTimeChanged: onDateTimeChanged,
      ),
    );
  }

  static void showSheet(
    BuildContext context, {
    required DateTime initialDateTime,
    required ValueChanged<DateTime> onDateTimeChanged,
  }) {
    DateTime tempDateTime = initialDateTime;
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          SizedBox(
            height: 180,
            child: CupertinoDatePicker(
              minimumYear: DateTime.now().year,
              initialDateTime: tempDateTime,
              mode: CupertinoDatePickerMode.date,
              onDateTimeChanged: (dateTime) {
                tempDateTime = dateTime;
              },
            ),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Done'),
          onPressed: () {
            onDateTimeChanged(tempDateTime);
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}
