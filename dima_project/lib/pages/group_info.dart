import 'package:dima_project/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class GroupInfo extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String adminName;
  const GroupInfo({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.adminName,
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
    DatabaseService.getGroupMembers(widget.groupId).then((val) {
      setState(() {
        members = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text("Group Info"),
        backgroundColor: CupertinoTheme.of(context).primaryColor,
        trailing: CupertinoButton(
          onPressed: () {
            showLeaveGroupDialog(context);
          },
          child: const Icon(CupertinoIcons.trash_fill,
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
                      widget.groupName.substring(0, 1).toUpperCase(),
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
                        widget.groupName,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Admin: ${widget.adminName}",
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
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          if (snapshot.data['members'] != null) {
            if (snapshot.data['members'].length > 0) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data['members'].length,
                itemBuilder: (context, index) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
                    child: CupertinoListTile(
                      leading: ClipOval(
                        child: Text(
                          snapshot.data['members'][index].substring(0, 1),
                          style: const TextStyle(
                            color: CupertinoColors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(snapshot.data['members'][index]),
                    ),
                  );
                },
              );
            } else {
              return const Center(
                child: Text("No members yet"),
              );
            }
          } else {
            return const Center(
              child: Text("No members yet"),
            );
          }
        } else {
          return const Center(
            child: CupertinoActivityIndicator(
              radius: 16,
            ),
          );
        }
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
              onPressed: () {
                DatabaseService.toggleGroupJoin(
                  widget.groupId,
                  FirebaseAuth.instance.currentUser!.uid,
                );
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text("Leave"),
            ),
          ],
        );
      },
    );
  }
}
