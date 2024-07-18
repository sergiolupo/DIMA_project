import 'package:flutter/cupertino.dart';

class Constants {
  static const primaryColor = CupertinoColors.systemPink;
  static const scaffoldBackgroundColor = CupertinoColors.white;
  static const barBackgroundColor = CupertinoColors.white;

  static const primaryColorDark = CupertinoColors.systemPurple;
  static const scaffoldBackgroundColorDark = CupertinoColors.black;
  static const barBackgroundColorDark = CupertinoColors.black;

  static const textColor = CupertinoColors.black;
  static const textColorDark = CupertinoColors.white;

  static final inputDecoration = BoxDecoration(
      color: CupertinoColors.white,
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(
        color: CupertinoColors.systemGrey4,
        width: 2.0,
      ));
}
