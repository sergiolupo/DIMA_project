import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/groups/edit_group_page.dart';
import 'package:dima_project/pages/groups/group_requests_page.dart';
import 'package:dima_project/pages/show_events_page.dart';
import 'package:dima_project/pages/show_medias_page.dart';
import 'package:dima_project/pages/show_news_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/categories_icon_mapper.dart';
import 'package:dima_project/widgets/home/user_tile.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class GroupInfoPage extends StatefulWidget {
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

class GroupInfoPageState extends State<GroupInfoPage> {
  List<UserData>? _requests;
  List<Message>? _media;
  List<Message>? _events;
  List<Message>? _news;
  Group? group;
  @override
  void initState() {
    super.initState();
    setState(() {
      group = widget.group;
    });
    init();
  }

  void init() async {
    List<UserData> users = [];
    List<Message> messages = [];
    users = (await DatabaseService.getGroupRequestsForGroup(widget.group.id));
    setState(() {
      _requests = users;
    });

    messages = (await DatabaseService.getGroupMessagesType(
        widget.group.id, Type.image));
    setState(() {
      _media = messages;
    });

    messages = (await DatabaseService.getGroupMessagesType(
        widget.group.id, Type.event));

    setState(() {
      _events = messages;
    });

    messages = (await DatabaseService.getGroupMessagesType(
        widget.group.id, Type.news));
    setState(() {
      _news = messages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _requests == null ||
            _media == null ||
            _events == null ||
            _news == null ||
            group == null
        ? const CupertinoActivityIndicator()
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              leading: CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.of(context).pop(group);
                },
                child: Icon(CupertinoIcons.back,
                    color: CupertinoTheme.of(context).primaryColor),
              ),
              middle: Text(
                "Group Info",
                style: TextStyle(
                    color: CupertinoTheme.of(context).primaryColor,
                    fontSize: 18.0),
              ),
              backgroundColor:
                  CupertinoTheme.of(context).scaffoldBackgroundColor,
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
                  init();
                },
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CupertinoTheme.of(context).primaryColor,
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
                        decoration: const BoxDecoration(),
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
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: group!.categories!
                                  .map((category) => Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Icon(
                                              CategoryIconMapper
                                                  .iconForCategory(category),
                                              size: 24,
                                              color: CupertinoTheme.of(context)
                                                  .primaryColor,
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              category,
                                              style: TextStyle(
                                                fontSize: 16,
                                                color:
                                                    CupertinoTheme.of(context)
                                                        .textTheme
                                                        .textStyle
                                                        .color,
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
                                  color: CupertinoTheme.of(context)
                                      .primaryContrastingColor,
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
                              CupertinoListTile(
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
                                    _requests!.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            child: Container(
                                              color: CupertinoTheme.of(context)
                                                  .primaryColor,
                                              child: Text(
                                                _requests!.length.toString(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.normal,
                                                  color: CupertinoColors.white,
                                                ),
                                              ),
                                            ),
                                          )
                                        : const SizedBox(),
                                    const SizedBox(width: 10),
                                    Icon(
                                      CupertinoIcons.right_chevron,
                                      color: CupertinoTheme.of(context)
                                          .primaryColor,
                                      size: 18,
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => GroupRequestsPage(
                                        groupId: widget.group.id,
                                        requests: _requests!,
                                      ),
                                    ),
                                  );
                                  init();
                                },
                              ),
                            CupertinoListTile(
                              padding: const EdgeInsets.all(0),
                              title: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.photo_on_rectangle,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text("Media"),
                                ],
                              ),
                              trailing: Row(
                                children: [
                                  _media!.isNotEmpty
                                      ? Text(
                                          _media!.length.toString(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                            color:
                                                CupertinoColors.opaqueSeparator,
                                          ),
                                        )
                                      : const SizedBox(),
                                  const SizedBox(width: 10),
                                  Icon(
                                    CupertinoIcons.right_chevron,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                    size: 18,
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => ShowMediasPage(
                                      id: widget.group.id,
                                      isGroup: true,
                                      medias: _media!,
                                    ),
                                  ),
                                );
                                init();
                              },
                            ),
                            const SizedBox(height: 10),
                            CupertinoListTile(
                              padding: const EdgeInsets.all(0),
                              title: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.calendar,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text("Events"),
                                ],
                              ),
                              trailing: Row(
                                children: [
                                  _events!.isNotEmpty
                                      ? Text(
                                          _events!.length.toString(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                            color:
                                                CupertinoColors.opaqueSeparator,
                                          ),
                                        )
                                      : const SizedBox(),
                                  const SizedBox(width: 10),
                                  Icon(
                                    CupertinoIcons.right_chevron,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                    size: 18,
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => ShowEventsPage(
                                      id: widget.group.id,
                                      isGroup: true,
                                      events: _events!,
                                    ),
                                  ),
                                );
                                init();
                              },
                            ),
                            const SizedBox(height: 10),
                            CupertinoListTile(
                              padding: const EdgeInsets.all(0),
                              title: Row(
                                children: [
                                  Icon(
                                    CupertinoIcons.news,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 10),
                                  const Text("News"),
                                ],
                              ),
                              trailing: Row(
                                children: [
                                  _news!.isNotEmpty
                                      ? Text(
                                          _news!.length.toString(),
                                          style: const TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.normal,
                                            color:
                                                CupertinoColors.opaqueSeparator,
                                          ),
                                        )
                                      : const SizedBox(),
                                  const SizedBox(width: 10),
                                  Icon(
                                    CupertinoIcons.right_chevron,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                    size: 18,
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => ShowNewsPage(
                                      id: widget.group.id,
                                      isGroup: true,
                                      news: _news!,
                                    ),
                                  ),
                                );
                                init();
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

                      if (widget.group.admin == userData.uuid) {
                        return Row(
                          children: [
                            Expanded(
                              child: UserTile(
                                user: userData,
                                uuid: widget.uuid,
                                isFollowing: null,
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
                        isFollowing: null,
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
