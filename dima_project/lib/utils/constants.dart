import 'package:flutter/cupertino.dart';

class Constants {
  static const primaryColor = CupertinoColors.systemPink;
  static const primaryColorDark = CupertinoColors.systemBlue;
  static final inputDecoration = BoxDecoration(
      color: CupertinoColors.white,
      borderRadius: BorderRadius.circular(8.0),
      border: Border.all(
        color: CupertinoColors.systemGrey4,
        width: 2.0,
      ));
}
