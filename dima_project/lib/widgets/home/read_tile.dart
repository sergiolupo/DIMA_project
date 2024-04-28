import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

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
        await DatabaseService.getUserDataFromUsername(widget.user.username);
    setState(() {
      _userData = userData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _userData == null
        ? const CupertinoActivityIndicator()
        : CupertinoListTile(
            leading: CreateImageWidget.getUserImage(_userData!.imagePath!,
                small: true),
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
