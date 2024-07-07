import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class GroupRequestTile extends StatefulWidget {
  final UserData user;
  final String groupId;
  const GroupRequestTile({
    super.key,
    required this.user,
    required this.groupId,
  });

  @override
  GroupRequestTileState createState() => GroupRequestTileState();
}

class GroupRequestTileState extends State<GroupRequestTile> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CupertinoListTile(
            leading: ClipOval(
              child: Container(
                width: 100,
                height: 100,
                color: CupertinoColors.lightBackgroundGray,
                child: CreateImageWidget.getUserImage(widget.user.imagePath!),
              ),
            ),
            title: Text(
              widget.user.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${widget.user.name} ${widget.user.surname}"),
          ),
        ),
        GestureDetector(
          onTap: () async {
            try {
              await DatabaseService.acceptGroupRequest(
                  widget.groupId, widget.user.uuid!);
            } catch (error) {
              debugPrint("Error occurred: $error");
            }
          },
          child: Container(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CupertinoColors.white),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: const Text(
                "Accept",
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            try {
              await DatabaseService.denyGroupRequest(
                  widget.groupId, widget.user.uuid!);
            } catch (error) {
              debugPrint("Error occurred: $error");
            }
          },
          child: Container(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              decoration: BoxDecoration(
                color: CupertinoTheme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CupertinoColors.white),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: const Text(
                "Deny",
                style: TextStyle(color: CupertinoColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
