import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/groups/edit_group_page.dart';
import 'package:dima_project/pages/groups/group_requests_page.dart';
import 'package:dima_project/pages/show_events_page.dart';
import 'package:dima_project/pages/show_medias_page.dart';
import 'package:dima_project/pages/show_news_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/categories_icon_mapper.dart';
import 'package:dima_project/widgets/home/user_tile.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupInfoPage extends ConsumerStatefulWidget {
  final String uuid;
  final Group group;
  const GroupInfoPage({
    super.key,
    required this.group,
    required this.uuid,
  });

  @override
  GroupInfoPageState createState() => GroupInfoPageState();
}

class GroupInfoPageState extends ConsumerState<GroupInfoPage> {
  Stream<int>? _numberOfRequestsStream;
  Stream<int>? _numberOfMediaStream;
  Stream<int>? _numberOfEventsStream;
  Stream<int>? _numberOfNewsStream;
  Group? group;
  AsyncValue<List<UserData>>? asyncFollowing;
  @override
  void initState() {
    super.initState();
    setState(() {
      group = widget.group;
    });
    getMembers();
    ref.read(followingProvider(widget.uuid));
  }

  void getMembers() {
    _numberOfRequestsStream =
        DatabaseService.getGroupRequestsStream(widget.group.id).map((event) {
      return event.length;
    });
    _numberOfMediaStream =
        DatabaseService.getGroupMessagesType(widget.group.id, Type.image).map(
      (event) {
        return event.length;
      },
    );
    _numberOfEventsStream =
        DatabaseService.getGroupMessagesType(widget.group.id, Type.event).map(
      (event) {
        return event.length;
      },
    );
    _numberOfNewsStream =
        DatabaseService.getGroupMessagesType(widget.group.id, Type.news).map(
      (event) {
        return event.length;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    asyncFollowing = ref.watch(followingProvider(widget.uuid));

    return _numberOfRequestsStream == null ||
            _numberOfMediaStream == null ||
            _numberOfEventsStream == null ||
            _numberOfNewsStream == null ||
            group == null
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
                onPressed: () async {
                  final Group? newGroup = await Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => EditGroupPage(
                                group: group!,
                                uuid: widget.uuid,
                              )));
                  if (newGroup != null) {
                    setState(() {
                      group = newGroup;
                    });
                  }
                },
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
                                  group!.imagePath!,
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  group!.name,
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
                              children: group!.categories!
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
                                    group!.description!,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (!group!.isPublic && group!.admin == widget.uuid)
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
                                  title: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.photo_on_rectangle,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text("Media"),
                                    ],
                                  ),
                                  trailing: Row(
                                    children: [
                                      int.parse(media.toString()) > 0
                                          ? Text(
                                              media.toString(),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal,
                                                color: CupertinoColors
                                                    .opaqueSeparator,
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
                            StreamBuilder<int>(
                              stream: _numberOfEventsStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CupertinoActivityIndicator();
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                final events = snapshot.data;
                                return CupertinoListTile(
                                  padding: const EdgeInsets.all(0),
                                  title: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.calendar,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text("Events"),
                                    ],
                                  ),
                                  trailing: Row(
                                    children: [
                                      int.parse(events.toString()) > 0
                                          ? Text(
                                              events.toString(),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal,
                                                color: CupertinoColors
                                                    .opaqueSeparator,
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
                                        builder: (context) => ShowEventsPage(
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
                            StreamBuilder<int>(
                              stream: _numberOfNewsStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CupertinoActivityIndicator();
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                final news = snapshot.data;
                                return CupertinoListTile(
                                  padding: const EdgeInsets.all(0),
                                  title: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.news,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text("News"),
                                    ],
                                  ),
                                  trailing: Row(
                                    children: [
                                      int.parse(news.toString()) > 0
                                          ? Text(
                                              news.toString(),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal,
                                                color: CupertinoColors
                                                    .opaqueSeparator,
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
                                        builder: (context) => ShowNewsPage(
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
    return group == null || group!.members == null
        ? const CupertinoActivityIndicator()
        : ListView.builder(
            shrinkWrap: true,
            itemCount: group!.members!.length,
            itemBuilder: (context, index) {
              return FutureBuilder(
                  future: DatabaseService.getUserData(group!.members![index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CupertinoActivityIndicator(); // Or any loading indicator
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final UserData userData = snapshot.data!;
                      return asyncFollowing!.when(
                        loading: () => const CupertinoActivityIndicator(),
                        error: (err, stack) => Text('Error: $err'),
                        data: (following) {
                          if (widget.group.admin == userData.uuid) {
                            return Row(
                              children: [
                                Expanded(
                                  child: UserTile(
                                    user: userData,
                                    uuid: widget.uuid,
                                    isFollowing: following
                                            .any((u) => u.uuid == userData.uuid)
                                        ? 1
                                        : userData.isPublic == false &&
                                                userData.requests!
                                                    .contains(widget.uuid)
                                            ? 2
                                            : 0,
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
                            isFollowing: following
                                    .any((u) => u.uuid == userData.uuid)
                                ? 1
                                : userData.isPublic == false &&
                                        userData.requests!.contains(widget.uuid)
                                    ? 2
                                    : 0,
                          );
                        },
                      );
                    }
                  });
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
                );
                if (!context.mounted) return;
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Leave"),
            ),
          ],
        );
      },
    );
  }
}
