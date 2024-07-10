import 'dart:typed_data';

import 'package:cached_network_image/cached_network_image.dart';
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

  static Widget getEventImageMemory(Uint8List image) {
    return ClipOval(
      child: Container(
        width: 100,
        height: 100,
        color: CupertinoColors.lightBackgroundGray,
        child: image.isNotEmpty
            ? Image.memory(
                image,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/default_event_image.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  static Widget getUserImageMemory(Uint8List image) {
    return ClipOval(
      child: Container(
        width: 100,
        height: 100,
        color: CupertinoColors.lightBackgroundGray,
        child: image.isNotEmpty
            ? Image.memory(
                image,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/default_user_image.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  static Widget getGroupImageMemory(Uint8List image) {
    return ClipOval(
      child: Container(
        width: 100,
        height: 100,
        color: CupertinoColors.lightBackgroundGray,
        child: image.isNotEmpty
            ? Image.memory(
                image,
                fit: BoxFit.cover,
              )
            : Image.asset(
                'assets/default_group_image.png',
                fit: BoxFit.cover,
              ),
      ),
    );
  }

  static getImage(String content, {bool small = false}) {
    debugPrint('content: $content');
    return Container(
      width: small ? 30 : 100,
      height: small ? 30 : 100,
      color: CupertinoColors.lightBackgroundGray,
      child: CachedNetworkImage(
        imageUrl: content,
        fit: BoxFit.cover,
      ),
    );
  }
}
