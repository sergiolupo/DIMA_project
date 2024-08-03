import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/chats/groups/edit_group_page.dart';
import 'package:dima_project/pages/chats/groups/group_chat_page.dart';
import 'package:dima_project/pages/chats/groups/group_requests_page.dart';
import 'package:dima_project/pages/chats/show_events_page.dart';
import 'package:dima_project/pages/chats/show_medias_page.dart';
import 'package:dima_project/pages/chats/show_news_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/category_util.dart';
import 'package:dima_project/widgets/home/user_tile.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/widgets/start_messaging_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

class GroupInfoPage extends StatefulWidget {
  final Group group;
  final Function? navigateToPage;
  final bool canNavigate;
  const GroupInfoPage({
    super.key,
    required this.group,
    this.navigateToPage,
    required this.canNavigate,
  });

  @override
  GroupInfoPageState createState() => GroupInfoPageState();
}

class GroupInfoPageState extends State<GroupInfoPage> {
  late Group group;

  final String uid = AuthService.uid;
  @override
  void initState() {
    super.initState();
    setState(() {
      group = widget.group;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        leading: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () {
            if (widget.canNavigate) {
              widget.navigateToPage!(GroupChatPage(
                  group: group,
                  canNavigate: widget.canNavigate,
                  navigateToPage: widget.navigateToPage));
              return;
            }
            Navigator.of(context).pop(group);
          },
          child: Icon(CupertinoIcons.back,
              color: CupertinoTheme.of(context).primaryColor),
        ),
        middle: Text(
          "Group Info",
          style: TextStyle(
              color: CupertinoTheme.of(context).primaryColor, fontSize: 18.0),
        ),
        backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        trailing: widget.group.admin == uid
            ? CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () async {
                  if (widget.canNavigate) {
                    widget.navigateToPage!(EditGroupPage(
                      group: group,
                      canNavigate: true,
                      navigateToPage: widget.navigateToPage,
                    ));
                    return;
                  }
                  final Group? newGroup = await Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => EditGroupPage(
                                group: group,
                                canNavigate: false,
                              )));

                  if (newGroup != null) {
                    setState(() {
                      group = newGroup;
                    });
                  }
                },
                child: Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: CupertinoTheme.of(context).primaryColor,
                  ),
                ),
              )
            : null,
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
                            group.imagePath!,
                          ),
                          const SizedBox(width: 20),
                          Text(
                            group.name,
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
                        children: group.categories!
                            .map((category) => Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        CategoryUtil.iconForCategory(category),
                                        size: 24,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        category,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: CupertinoTheme.of(context)
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
                              group.description!,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      if (!group.isPublic && group.admin == uid)
                        FutureBuilder(
                          future: DatabaseService.getGroupRequestsForGroup(
                              group.id),
                          builder: (context, snapshot) {
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
                                  (snapshot.connectionState ==
                                              ConnectionState.waiting ||
                                          snapshot.hasError)
                                      ? const SizedBox()
                                      : ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          child: Container(
                                            color: CupertinoTheme.of(context)
                                                .primaryColor,
                                            child: Text(
                                              snapshot.data!.length.toString(),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal,
                                                color: CupertinoColors.white,
                                              ),
                                            ),
                                          ),
                                        ),
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
                                if (snapshot.connectionState ==
                                        ConnectionState.waiting ||
                                    snapshot.hasError) return;
                                final List<UserData> requests = snapshot.data!;
                                if (widget.canNavigate) {
                                  widget.navigateToPage!(GroupRequestsPage(
                                    group: group,
                                    requests: requests,
                                    canNavigate: true,
                                    navigateToPage: widget.navigateToPage,
                                  ));
                                  return;
                                }

                                Navigator.of(context).push(
                                  CupertinoPageRoute(
                                    builder: (context) => GroupRequestsPage(
                                      group: group,
                                      requests: requests,
                                      canNavigate: false,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      FutureBuilder(
                        future: DatabaseService.getGroupMessagesType(
                            group.id, Type.image),
                        builder: (context, snapshot) {
                          return CupertinoListTile(
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
                                (snapshot.connectionState ==
                                            ConnectionState.waiting ||
                                        snapshot.hasError ||
                                        snapshot.data!.isEmpty)
                                    ? const SizedBox()
                                    : Text(
                                        snapshot.data!.length.toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                          color:
                                              CupertinoColors.opaqueSeparator,
                                        ),
                                      ),
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
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  snapshot.hasError) return;
                              final List<Message> media = snapshot.data!;
                              if (widget.canNavigate) {
                                widget.navigateToPage!(ShowMediasPage(
                                  isGroup: true,
                                  medias: media,
                                  canNavigate: true,
                                  navigateToPage: widget.navigateToPage,
                                  group: group,
                                ));
                                return;
                              }
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => ShowMediasPage(
                                    isGroup: true,
                                    medias: media,
                                    group: group,
                                    canNavigate: false,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder(
                        future: DatabaseService.getGroupMessagesType(
                            group.id, Type.event),
                        builder: (context, snapshot) {
                          return CupertinoListTile(
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
                                (snapshot.connectionState ==
                                            ConnectionState.waiting ||
                                        snapshot.hasError ||
                                        snapshot.data!.isEmpty)
                                    ? const SizedBox()
                                    : Text(
                                        snapshot.data!.length.toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                          color:
                                              CupertinoColors.opaqueSeparator,
                                        ),
                                      ),
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
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  snapshot.hasError) return;
                              final List<Message> events = snapshot.data!;
                              if (widget.canNavigate) {
                                widget.navigateToPage!(ShowEventsPage(
                                  group: group,
                                  isGroup: true,
                                  events: events,
                                  canNavigate: true,
                                  navigateToPage: widget.navigateToPage,
                                ));
                                return;
                              }
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => ShowEventsPage(
                                    group: group,
                                    canNavigate: false,
                                    isGroup: true,
                                    events: events,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder(
                        future: DatabaseService.getGroupMessagesType(
                            group.id, Type.news),
                        builder: (context, snapshot) {
                          return CupertinoListTile(
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
                                (snapshot.connectionState ==
                                            ConnectionState.waiting ||
                                        snapshot.hasError ||
                                        snapshot.data!.isEmpty)
                                    ? const SizedBox()
                                    : Text(
                                        snapshot.data!.length.toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                          color:
                                              CupertinoColors.opaqueSeparator,
                                        ),
                                      ),
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
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  snapshot.hasError) return;
                              final List<Message> news = snapshot.data!;
                              if (widget.canNavigate) {
                                widget.navigateToPage!(ShowNewsPage(
                                  group: group,
                                  isGroup: true,
                                  news: news,
                                  canNavigate: true,
                                  navigateToPage: widget.navigateToPage,
                                ));
                                return;
                              }
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => ShowNewsPage(
                                    group: group,
                                    canNavigate: false,
                                    isGroup: true,
                                    news: news,
                                  ),
                                ),
                              );
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
    return ListView.builder(
      shrinkWrap: true,
      itemCount: group.members!.length,
      itemBuilder: (context, index) {
        return FutureBuilder(
            future: DatabaseService.getUserData(group.members![index]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Shimmer.fromColors(
                  baseColor: CupertinoTheme.of(context).primaryContrastingColor,
                  highlightColor:
                      CupertinoTheme.of(context).primaryContrastingColor,
                  child: CupertinoListTile(
                    leading: ClipOval(
                      child: Container(
                        color:
                            CupertinoTheme.of(context).primaryContrastingColor,
                        width: 50.0,
                        height: 50.0,
                      ),
                    ),
                    title: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          shape: BoxShape.rectangle,
                          color: CupertinoTheme.of(context)
                              .primaryContrastingColor),
                      width: 50.0,
                      height: 15.0,
                    ),
                    subtitle: Container(
                      width: 70.0,
                      height: 10.0,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: CupertinoTheme.of(context)
                              .primaryContrastingColor),
                    ),
                  ),
                );
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                final UserData userData = snapshot.data!;

                if (group.admin == userData.uid) {
                  return Row(
                    children: [
                      Expanded(
                        child: UserTile(
                          user: userData,
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
                  group.id,
                );
                if (!context.mounted) return;

                if (widget.canNavigate) {
                  Navigator.of(context).pop();
                  widget.navigateToPage!(const StartMessagingWidget());
                  return;
                }
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
