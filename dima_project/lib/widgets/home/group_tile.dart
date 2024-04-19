import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chat_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class GroupTile extends StatefulWidget {
  final UserData user;
  final Group group;
  final UserData? visitor;
  final bool isJoined;
  const GroupTile({
    super.key,
    required this.user,
    required this.group,
    this.visitor,
    required this.isJoined, // Updated this
  });

  @override
  GroupTileState createState() => GroupTileState();
}

class GroupTileState extends State<GroupTile> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (widget.isJoined) {
                // Updated this condition
                Navigator.of(context, rootNavigator: true).push(
                  CupertinoPageRoute(
                    builder: (context) => ChatPage(
                      user: widget.user,
                      group: widget.group,
                    ),
                  ),
                );
              }
            },
            child: CupertinoListTile(
              leading: CreateImageWidget.getGroupImage(widget.group.imagePath!),
              title: Text(
                widget.group.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Admin: ${widget.group.admin}"),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            try {
              // Updated this condition
              if (widget.visitor != null) {
                await DatabaseService.toggleGroupJoin(
                  widget.group.id,
                  FirebaseAuth.instance.currentUser!.uid,
                  widget.visitor!.username,
                );
              } else {
                await DatabaseService.toggleGroupJoin(
                  widget.group.id,
                  FirebaseAuth.instance.currentUser!.uid,
                  widget.user.username,
                );
              }
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
              child: Text(
                widget.isJoined ? "Joined" : "Join Now", // Updated this text
                style: const TextStyle(color: CupertinoColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
