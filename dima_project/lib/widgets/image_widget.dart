import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class CreateImageWidget {
  static Widget getUserImage(Uint8List? imagePath, {bool small = false}) {
    return ClipOval(
      child: Container(
        width: small ? 30 : 100,
        height: small ? 30 : 100,
        color: CupertinoColors.lightBackgroundGray,
        child: imagePath != null
            ? Image.memory(
                imagePath,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/default_user_image.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  static Widget getGroupImage(Uint8List? imagePath, {bool small = false}) {
    return ClipOval(
      child: Container(
        width: small ? 50 : 100,
        height: small ? 50 : 100,
        color: CupertinoColors.lightBackgroundGray,
        child: imagePath != null
            ? Image.memory(
                imagePath,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/default_group_image.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
