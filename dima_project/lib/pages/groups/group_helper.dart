import 'package:flutter/cupertino.dart';

class GroupHelper {
  static bool validateFirstPage(
      BuildContext context, String name, String description) {
    if (name.isEmpty) {
      _showErrorDialog(context, 'Event name is required');
      return false;
    }
    if (description.isEmpty) {
      _showErrorDialog(context, 'Event description is required');
      return false;
    }
    return true;
  }

  static bool validateSecondPage(
      BuildContext context, List<String> categories) {
    if (categories.isEmpty) {
      _showErrorDialog(context, 'Please select at least one category');
      return false;
    }

    return true;
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Validation Error'),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
