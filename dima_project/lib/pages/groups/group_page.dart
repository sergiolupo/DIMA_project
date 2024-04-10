import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/group_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class GroupPage extends StatefulWidget {
  final UserData user;
  const GroupPage({super.key, required this.user});

  @override
  GroupPageState createState() => GroupPageState();
}

class GroupPageState extends State<GroupPage> {
  Stream<List<DocumentSnapshot<Map<String, dynamic>>>>? _groupsStream;
  String groupName = "";

  @override
  void initState() {
    super.initState();
    _subscribeToGroups();
  }

  void _subscribeToGroups() {
    _groupsStream = DatabaseService.getGroupsStream(widget.user.username);
  }

  @override
  Widget build(BuildContext context) {
    return (_groupsStream == null)
        ? const CupertinoPageScaffold(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          )
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              backgroundColor: CupertinoTheme.of(context).primaryColor,
              middle: const Text(
                "Chat",
                style: TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 27,
                ),
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  groupList(),
                  Positioned(
                    bottom: 20,
                    right: 20,
                    child: CupertinoButton(
                      onPressed: () {
                        context.go("/createGroup", extra: widget.user);
                      },
                      child: const Icon(CupertinoIcons.add, size: 30),
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  Widget groupList() {
    return StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
      stream: _groupsStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          var data = snapshot.data!;
          if (data.isNotEmpty) {
            return ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final group = Group.convertToGroup(data[index]);
                return GroupChatTile(
                  user: widget.user,
                  group: group,
                );
              },
            );
          } else {
            return noGroupWidget();
          }
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(),
          );
        } else {
          return Container(); // Return an empty container or handle other cases as needed
        }
      },
    );
  }

  Widget noGroupWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(CupertinoIcons.group,
              size: 100, color: CupertinoColors.systemGrey),
          SizedBox(height: 20),
          Text(
            "No groups yet",
            style: TextStyle(
              color: CupertinoColors.systemGrey,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 20),
          Text(
            "Create a group to start chatting",
            style: TextStyle(color: CupertinoColors.systemGrey, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
