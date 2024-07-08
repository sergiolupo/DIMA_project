import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/groups/edit_group_page.dart';
import 'package:dima_project/pages/groups/group_requests_page.dart';
import 'package:dima_project/pages/show_medias_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/categories_icon_mapper.dart';
import 'package:dima_project/widgets/home/user_tile.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class GroupInfoPage extends StatefulWidget {
  final Group group;
  final String uuid;

  const GroupInfoPage({
    super.key,
    required this.group,
    required this.uuid,
  });

  @override
  GroupInfoPageState createState() => GroupInfoPageState();
}

class GroupInfoPageState extends State<GroupInfoPage> {
  Stream<List<dynamic>>? _membersStream;
  Stream<int>? _numberOfRequestsStream;
  Stream<int>? _numberOfMediaStream;
  @override
  void initState() {
    super.initState();
    getMembers();
  }

  void getMembers() {
    _membersStream = DatabaseService.getGroupMembers(widget.group.id);
    _numberOfRequestsStream =
        DatabaseService.getGroupRequests(widget.group.id).map((event) {
      return event.length;
    });
    _numberOfMediaStream = DatabaseService.getGroupMedia(widget.group.id).map(
      (event) {
        return event.length;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _membersStream == null || _numberOfRequestsStream == null
        ? const CupertinoActivityIndicator()
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              leading: CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(CupertinoIcons.back,
                    color: CupertinoColors.white),
              ),
              middle: const Text("Group Info"),
              backgroundColor: CupertinoTheme.of(context).primaryColor,
              trailing: CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => EditGroupPage(
                              group: widget.group,
                            ))),
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: CupertinoColors.white,
                  ),
                ),
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
                        ),
                        child: Column(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CreateImageWidget.getGroupImage(
                                  widget.group.imagePath!,
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  widget.group.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: widget.group.categories!
                                  .map((category) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              CategoryIconMapper
                                                  .iconForCategory(category),
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
                            const SizedBox(height: 10),
                            Container(
                              alignment: Alignment.centerLeft,
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                  color: CupertinoColors.lightBackgroundGray,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    "Description: ",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    widget.group.description!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (!widget.group.isPublic &&
                                widget.group.admin == widget.uuid)
                              StreamBuilder<int>(
                                stream: _numberOfRequestsStream,
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const CupertinoActivityIndicator();
                                  }
                                  if (snapshot.hasError) {
                                    return Text('Error: ${snapshot.error}');
                                  }
                                  final requests = snapshot.data;
                                  return CupertinoListTile(
                                    padding: const EdgeInsets.all(0),
                                    title: const Row(
                                      children: [
                                        Icon(
                                          CupertinoIcons.bell,
                                          color: CupertinoColors.black,
                                        ),
                                        SizedBox(width: 10),
                                        Text("Requests"),
                                      ],
                                    ),
                                    trailing: Row(
                                      children: [
                                        int.parse(requests.toString()) > 0
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                child: Container(
                                                  color:
                                                      CupertinoTheme.of(context)
                                                          .primaryColor,
                                                  child: Text(
                                                    requests.toString(),
                                                    style: const TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color:
                                                          CupertinoColors.white,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : const SizedBox(),
                                        const SizedBox(width: 10),
                                        const Icon(
                                          CupertinoIcons.right_chevron,
                                          color: CupertinoColors.black,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.of(context).push(
                                        CupertinoPageRoute(
                                          builder: (context) =>
                                              GroupRequestsPage(
                                            groupId: widget.group.id,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            StreamBuilder<int>(
                              stream: _numberOfMediaStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CupertinoActivityIndicator();
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                final media = snapshot.data;
                                return CupertinoListTile(
                                  padding: const EdgeInsets.all(0),
                                  title: const Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.photo_on_rectangle,
                                        color: CupertinoColors.black,
                                      ),
                                      SizedBox(width: 10),
                                      Text("Media"),
                                    ],
                                  ),
                                  trailing: Row(
                                    children: [
                                      int.parse(media.toString()) > 0
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                color:
                                                    CupertinoTheme.of(context)
                                                        .primaryColor,
                                                child: Text(
                                                  media.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color:
                                                        CupertinoColors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        CupertinoIcons.right_chevron,
                                        color: CupertinoColors.black,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  onTap: () => {
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => ShowMediasPage(
                                          id: widget.group.id,
                                          isGroup: true,
                                        ),
                                      ),
                                    ),
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                          ],
                        ),
                      ),
                      const Text(
                        "Members",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      Container(
                        constraints: const BoxConstraints(
                            maxHeight: 300), // Limit height of ListView
                        child: memberList(),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          showLeaveGroupDialog(context);
                        },
                        child: const Text('Exit Group',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.systemRed,
                            ),
                            textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
  }

  Widget memberList() {
    return StreamBuilder<List<dynamic>>(
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
          final data = snapshot.data;
          if (data == null || data.isEmpty) {
            return const Center(
              child: Text("No members in this group"),
            );
          }
          var members = snapshot.data!;
          return ListView.builder(
            shrinkWrap: true,
            itemCount: members.length,
            itemBuilder: (context, index) {
              return StreamBuilder(
                stream: DatabaseService.getUserDataFromUUID(members[index]),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CupertinoActivityIndicator(); // Or any loading indicator
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final UserData userData = snapshot.data!;
                    return StreamBuilder(
                        stream: DatabaseService.isFollowing(
                            userData.uuid!, widget.uuid),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CupertinoActivityIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final isFollowing = snapshot.data!;
                            if (userData.uuid == widget.group.admin) {
                              return Row(
                                children: [
                                  Expanded(
                                    child: UserTile(
                                      user: userData,
                                      uuid: widget.uuid,
                                      isFollowing: isFollowing,
                                    ),
                                  ),
                                  const Text(
                                    "Admin",
                                    style: TextStyle(
                                      color: CupertinoColors.systemGrey4,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              );
                            }
                            return UserTile(
                              user: userData,
                              uuid: widget.uuid,
                              isFollowing: isFollowing,
                            );
                          }
                        });
                  }
                },
              );
            },
          );
        });
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
