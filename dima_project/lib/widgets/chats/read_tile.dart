import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

class ReadTile extends StatefulWidget {
  final ReadBy user;
  const ReadTile({super.key, required this.user});

  @override
  ReadTileState createState() => ReadTileState();
}

class ReadTileState extends State<ReadTile> {
  UserData? _userData;
  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    final userData =
        await (DatabaseService()).getUserData(widget.user.username);

    setState(() {
      _userData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _userData == null
        ? Shimmer.fromColors(
            baseColor: CupertinoTheme.of(context).primaryContrastingColor,
            highlightColor: CupertinoTheme.of(context).primaryContrastingColor,
            child: CupertinoListTile(
              leading: ClipOval(
                child: Container(
                  width: 30,
                  height: 30,
                  color: CupertinoTheme.of(context).primaryContrastingColor,
                ),
              ),
              title: Container(
                width: 100,
                height: 50,
                color: CupertinoTheme.of(context).primaryContrastingColor,
              ),
              subtitle: Container(
                width: 100,
                height: 50,
                color: CupertinoTheme.of(context).primaryContrastingColor,
              ),
            ),
          )
        : CupertinoListTile(
            leading: CreateImageWidget.getUserImage(_userData!.imagePath!, 0),
            title: Text(
              _userData!.username,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              'Read at ${DateUtil.getFormattedDateAndTime(context: context, time: widget.user.readAt.microsecondsSinceEpoch.toString())}',
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          );
  }
}
