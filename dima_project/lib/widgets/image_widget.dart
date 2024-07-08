import 'package:flutter/cupertino.dart';

class CreateImageWidget {
  static Widget getUserImage(String imagePath, {bool small = false}) {
    return ClipOval(
      child: Container(
        width: small ? 30 : 100,
        height: small ? 30 : 100,
        color: CupertinoColors.lightBackgroundGray,
        child: imagePath != ''
            ? Image.network(
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

  static Widget getGroupImage(String imagePath, {bool small = false}) {
    return ClipOval(
      child: Container(
        width: small ? 30 : 100,
        height: small ? 30 : 100,
        color: CupertinoColors.lightBackgroundGray,
        child: imagePath != ''
            ? Image.network(
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

  static Widget getEventImage(String imagePath, {bool small = false}) {
    return ClipOval(
      child: Container(
        width: small ? 30 : 100,
        height: small ? 30 : 100,
        color: CupertinoColors.lightBackgroundGray,
        child: imagePath != ''
            ? Image.network(
                imagePath,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/default_event_image.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  static getImage(String content, {bool small = false}) {
    return Container(
      width: small ? 30 : 100,
      height: small ? 30 : 100,
      color: CupertinoColors.lightBackgroundGray,
      child: Image.network(
        content,
        fit: BoxFit.cover,
      ),
    );
  }
}
