import 'package:dima_project/models/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class GroupTile extends StatefulWidget {
  final UserData user;
  final String groupId;
  final String groupName;
  const GroupTile({
    super.key,
    required this.user,
    required this.groupId,
    required this.groupName,
  });

  @override
  GroupTileState createState() => GroupTileState();
}

class GroupTileState extends State<GroupTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/chat', extra: {
          "username": widget.user.username,
          "groupName": widget.groupName,
          "groupId": widget.groupId,
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: CupertinoButton(
          onPressed: () {
            context.go('/chat', extra: {
              "username": widget.user.username,
              "groupName": widget.groupName,
              "groupId": widget.groupId,
            });
          },
          padding: EdgeInsets.zero,
          child: CupertinoListTile(
            leading: ClipOval(
              child: Text(
                widget.groupName.substring(0, 1).toUpperCase(),
                textAlign: TextAlign.center,
              ),
            ),
            title: Text(
              widget.groupName,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Join the conversation as ${widget.user.username}"),
          ),
        ),
      ),
    );
  }
}
