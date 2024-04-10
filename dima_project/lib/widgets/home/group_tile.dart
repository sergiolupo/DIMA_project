import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class GroupChatTile extends StatefulWidget {
  final UserData user;
  final Group group;
  const GroupChatTile({super.key, required this.user, required this.group});

  @override
  GroupChatTileState createState() => GroupChatTileState();
}

class GroupChatTileState extends State<GroupChatTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/chat', extra: {
          "user": widget.user,
          "group": widget.group,
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: CupertinoButton(
          onPressed: () {
            context.go('/chat', extra: {
              "user": widget.user,
              "group": widget.group,
            });
          },
          padding: EdgeInsets.zero,
          child: CupertinoListTile(
            leading: CreateImageWidget.getGroupImage(widget.group.imagePath!),
            title: Text(
              widget.group.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Join the conversation as ${widget.user.username}"),
          ),
        ),
      ),
    );
  }
}
