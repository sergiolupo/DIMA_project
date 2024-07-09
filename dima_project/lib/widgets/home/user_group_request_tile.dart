import 'package:dima_project/models/group.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class UserGroupRequestTile extends StatefulWidget {
  final Group group;
  final String uuid;
  const UserGroupRequestTile({
    super.key,
    required this.group,
    required this.uuid,
  });

  @override
  UserGroupRequestTileState createState() => UserGroupRequestTileState();
}

class UserGroupRequestTileState extends State<UserGroupRequestTile> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CupertinoListTile(
            leading: CreateImageWidget.getGroupImage(widget.group.imagePath!),
            title: Text(
              widget.group.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Description: ${widget.group.description}",
                maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
        ),
        GestureDetector(
          onTap: () async {
            try {
              await DatabaseService.acceptUserGroupRequest(
                  widget.group.id, widget.uuid);
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
              await DatabaseService.denyUserGroupRequest(
                  widget.group.id, widget.uuid);
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
