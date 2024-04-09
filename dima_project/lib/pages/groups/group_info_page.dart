import 'package:dima_project/models/group.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class GroupInfo extends StatefulWidget {
  final Group group;
  final String username;
  const GroupInfo({
    super.key,
    required this.group,
    required this.username,
  });

  @override
  GroupInfoState createState() => GroupInfoState();
}

class GroupInfoState extends State<GroupInfo> {
  Stream? members;
  @override
  void initState() {
    getMembers();
    super.initState();
  }

  getMembers() async {
    // Get group members
    DatabaseService.getGroupMembers(widget.group.id).then((val) {
      setState(() {
        members = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          onPressed: () {
            context.go('/chat', extra: {
              "username": widget.username,
              "group": widget.group,
            });
          },
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
        ),
        middle: const Text("Group Info"),
        backgroundColor: CupertinoTheme.of(context).primaryColor,
        trailing: CupertinoButton(
          onPressed: () {
            showLeaveGroupDialog(context);
          },
          child: const Icon(FontAwesomeIcons.signOutAlt,
              color: CupertinoColors.white),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: CupertinoColors.white,
                border: Border(
                    bottom: BorderSide(color: CupertinoColors.systemGrey)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    child: Text(
                      widget.group.name.substring(0, 1).toUpperCase(),
                      style: const TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.group.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Admin: ${widget.group.admin}",
                        style: const TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.systemGrey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(child: memberList()),
          ],
        ),
      ),
    );
  }

  Widget memberList() {
    return StreamBuilder(
      stream: members,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CupertinoActivityIndicator(
              radius: 16,
            ),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        final data = snapshot.data?.data();
        if (data == null ||
            data['members'] == null ||
            data['members'].isEmpty) {
          return const Center(
            child: Text("No members yet"),
          );
        }
        final List<dynamic> members = data['members'];
        return ListView.builder(
          shrinkWrap: true,
          itemCount: members.length,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: CupertinoListTile(
                leading: ClipOval(
                  child: Text(
                    members[index].substring(0, 1),
                    style: const TextStyle(
                      color: CupertinoColors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(members[index]),
              ),
            );
          },
        );
      },
    );
  }

  void showLeaveGroupDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text("Leave Group"),
          content: const Text("Are you sure you want to leave this group?"),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                await DatabaseService.toggleGroupJoin(
                  widget.group.id,
                  FirebaseAuth.instance.currentUser!.uid,
                  widget.username,
                );
                if (!context.mounted) return;
                Navigator.of(context).pop();
                context.go('/home', extra: 1);
              },
              child: const Text("Leave"),
            ),
          ],
        );
      },
    );
  }
}
