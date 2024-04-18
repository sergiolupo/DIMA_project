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
  const GroupTile({
    super.key,
    required this.user,
    required this.group,
    this.visitor,
  });

  @override
  GroupTileState createState() => GroupTileState();
}

class GroupTileState extends State<GroupTile> {
  bool _isJoined = false;

  @override
  void initState() {
    super.initState();
    _checkIfJoined(); // Check if user is already joined when widget is initialized
  }

  void _checkIfJoined() async {
    try {
      if (widget.visitor != null) {
        await DatabaseService.isUserJoined(
          widget.group.id,
          widget.visitor!.username,
        ).then((isJoined) {
          if (mounted) {
            setState(() {
              _isJoined = isJoined;
            });
          }
        });
      } else {
        await DatabaseService.isUserJoined(
          widget.group.id,
          widget.user.username,
        ).then((isJoined) {
          if (mounted) {
            setState(() {
              _isJoined = isJoined;
            });
          }
        });
      }
    } catch (error) {
      debugPrint("Error occurred: $error");
      if (mounted) {
        setState(() {
          _isJoined = false; // Handle error by setting _isJoined to false
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_isJoined) {
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

              if (mounted) {
                setState(() {
                  _checkIfJoined();
                });
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
                _isJoined ? "Joined" : "Join Now",
                style: const TextStyle(color: CupertinoColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
