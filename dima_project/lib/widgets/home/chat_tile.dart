import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class ChatTile extends StatefulWidget {
  final UserData user;
  final Group? group;
  final PrivateChat? privateChat;

  const ChatTile({super.key, required this.user, this.group, this.privateChat});

  @override
  ChatTileState createState() => ChatTileState();
}

class ChatTileState extends State<ChatTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.group != null) {
          context.go('/chat', extra: {
            "user": widget.user,
            "group": widget.group,
          });
        } else {
          context.go('/chat', extra: {
            "user": widget.user,
            "privateChat": widget.privateChat,
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24, // Adjust padding based on screen width
          vertical: 16,
        ),
        child: CupertinoButton(
          onPressed: () {
            if (widget.group != null) {
              context.go('/chat', extra: {
                "user": widget.user,
                "group": widget.group,
              });
            } else {
              context.go('/chat', extra: {
                "user": widget.user,
                "privateChat": widget.privateChat,
              });
            }
          },
          padding: EdgeInsets.zero,
          child: CupertinoListTile(
            leading: widget.group != null
                ? CreateImageWidget.getGroupImage(widget.group!.imagePath!)
                : const SizedBox(),
            title: Text(
              widget.group == null
                  ? widget.privateChat!.user
                  : widget.group!.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("Join the conversation as ${widget.user.username}"),
          ),
        ),
      ),
    );
  }
}
