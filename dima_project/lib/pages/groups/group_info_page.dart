import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/categories_icon_mapper.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class GroupInfo extends StatefulWidget {
  final Group group;
  final UserData user;

  const GroupInfo({
    super.key,
    required this.group,
    required this.user,
  });

  @override
  GroupInfoState createState() => GroupInfoState();
}

class GroupInfoState extends State<GroupInfo> {
  Stream<List<DocumentSnapshot<Map<String, dynamic>>>>? _membersStream;
  @override
  void initState() {
    super.initState();
    getMembers();
  }

  void getMembers() async {
    final members = await DatabaseService.getGroupMembers(widget.group.id);
    setState(() {
      _membersStream = members;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          onPressed: () {
            context.go('/chat', extra: {
              "user": widget.user,
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
      child: CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(
                    color: CupertinoColors.white,
                    border: Border(
                        bottom: BorderSide(color: CupertinoColors.systemGrey)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          CreateImageWidget.getGroupImage(
                              widget.group.imagePath!,
                              small: true),
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
                      const SizedBox(height: 10),
                      Text(
                        widget.group.description!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: widget.group.categories!
                            .map((category) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        CategoryIconMapper.iconForCategory(
                                            category),
                                        size: 24,
                                        color: CupertinoColors.black,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        category,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: CupertinoColors.black,
                                        ),
                                      ),
                                    ],
                                  ),
                                ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(
                      maxHeight: 300), // Limit height of ListView
                  child: memberList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget memberList() {
    if (_membersStream == null) {
      return const Center(
        child: CupertinoActivityIndicator(
          radius: 16,
        ),
      );
    }
    return StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
      stream: _membersStream,
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
        if (snapshot.data!.isEmpty) {
          return const Center(
            child: Text("No members in this group"),
          );
        }
        var members = snapshot.data!;

        return ListView.builder(
          shrinkWrap: true,
          itemCount: members.length,
          itemBuilder: (context, index) {
            final user = UserData.convertToUserData(members[index]);

            return GestureDetector(
              onTap: () {
                context.go('/userprofile',
                    extra: {"user": user, "visitor": widget.user});
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    CreateImageWidget.getUserImage(user.imagePath!,
                        small: true),
                    const SizedBox(width: 20),
                    Text(
                      user.username,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
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
                  widget.user.username,
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
