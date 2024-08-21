import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/chats/groups/add_members_group_page.dart';
import 'package:dima_project/pages/chats/groups/edit_group_page.dart';
import 'package:dima_project/pages/chats/groups/group_chat_page.dart';
import 'package:dima_project/pages/chats/groups/group_requests_page.dart';
import 'package:dima_project/pages/chats/show_events_page.dart';
import 'package:dima_project/pages/chats/show_medias_page.dart';
import 'package:dima_project/pages/chats/show_news_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/utils/category_util.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/notification_widget.dart';
import 'package:dima_project/widgets/user_tile.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:dima_project/widgets/start_messaging_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

class GroupInfoPage extends StatefulWidget {
  final Group group;
  final Function? navigateToPage;
  final bool canNavigate;
  final DatabaseService databaseService;
  final NotificationService notificationService;
  final ImagePicker imagePicker;
  const GroupInfoPage({
    super.key,
    required this.group,
    this.navigateToPage,
    required this.canNavigate,
    required this.databaseService,
    required this.notificationService,
    required this.imagePicker,
  });

  @override
  GroupInfoPageState createState() => GroupInfoPageState();
}

class GroupInfoPageState extends State<GroupInfoPage> {
  late Group group;

  final String uid = AuthService.uid;
  late final DatabaseService _databaseService;
  bool notify = true;

  @override
  void initState() {
    _databaseService = widget.databaseService;
    init();
    super.initState();
    setState(() {
      group = widget.group;
    });
  }

  init() async {
    _databaseService.getNotification(widget.group.id, true).then((value) {
      setState(() {
        notify = value;
      });
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
                storageService: StorageService(),
                group: group,
                canNavigate: widget.canNavigate,
                navigateToPage: widget.navigateToPage,
                databaseService: _databaseService,
                notificationService: widget.notificationService,
                imagePicker: ImagePicker(),
                eventService: EventService(),
              ));
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
                      imagePicker: widget.imagePicker,
                    ));
                    return;
                  }
                  final Group? newGroup = await Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => EditGroupPage(
                                group: group,
                                canNavigate: false,
                                imagePicker: widget.imagePicker,
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
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        primary: true,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20),
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
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color:
                            CupertinoTheme.of(context).primaryContrastingColor,
                      ),
                      child: Column(
                        children: [
                          if (!group.isPublic && group.admin == uid)
                            FutureBuilder(
                              future: _databaseService
                                  .getGroupRequestsForGroup(group.id),
                              builder: (context, snapshot) {
                                return CupertinoListTile(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  title: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.bell,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text("Requests"),
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
                                                color: CupertinoColors
                                                    .opaqueSeparator,
                                              ),
                                            ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        CupertinoIcons.right_chevron,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  onTap: () async {
                                    if (snapshot.connectionState ==
                                            ConnectionState.waiting ||
                                        snapshot.hasError) return;
                                    final List<UserData> requests =
                                        snapshot.data!;
                                    if (widget.canNavigate) {
                                      widget.navigateToPage!(GroupRequestsPage(
                                        group: group,
                                        requests: requests,
                                        canNavigate: widget.canNavigate,
                                        navigateToPage: widget.navigateToPage,
                                        notificationService:
                                            widget.notificationService,
                                        databaseService: _databaseService,
                                      ));
                                      return;
                                    }

                                    final Group? newGroup =
                                        await Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => GroupRequestsPage(
                                          group: group,
                                          requests: requests,
                                          canNavigate: widget.canNavigate,
                                          notificationService:
                                              widget.notificationService,
                                          databaseService: _databaseService,
                                        ),
                                      ),
                                    );
                                    if (newGroup != null) {
                                      group = newGroup;
                                    }
                                    setState(() {});
                                  },
                                );
                              },
                            ),
                          if (!group.isPublic && group.admin == uid)
                            Container(
                              height: 1,
                              color: CupertinoColors.opaqueSeparator
                                  .withOpacity(0.2),
                            ),
                          FutureBuilder(
                            future: _databaseService.getGroupMessagesType(
                                group.id, Type.image),
                            builder: (context, snapshot) {
                              return CupertinoListTile(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
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
                                              color: CupertinoColors
                                                  .opaqueSeparator,
                                            ),
                                          ),
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
                                  if (snapshot.connectionState ==
                                          ConnectionState.waiting ||
                                      snapshot.hasError) return;
                                  final List<Message> media = snapshot.data!;
                                  if (widget.canNavigate) {
                                    widget.navigateToPage!(ShowImagesPage(
                                      isGroup: true,
                                      medias: media,
                                      canNavigate: true,
                                      navigateToPage: widget.navigateToPage,
                                      group: group,
                                      databaseService: _databaseService,
                                      notificationService:
                                          widget.notificationService,
                                    ));
                                    return;
                                  }
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => ShowImagesPage(
                                        isGroup: true,
                                        medias: media,
                                        group: group,
                                        canNavigate: false,
                                        databaseService: _databaseService,
                                        notificationService:
                                            widget.notificationService,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          Container(
                            height: 1,
                            color: CupertinoColors.opaqueSeparator
                                .withOpacity(0.2),
                          ),
                          FutureBuilder(
                            future: _databaseService.getGroupMessagesType(
                                group.id, Type.event),
                            builder: (context, snapshot) {
                              return CupertinoListTile(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
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
                                              color: CupertinoColors
                                                  .opaqueSeparator,
                                            ),
                                          ),
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
                                      databaseService: _databaseService,
                                      notificationService:
                                          widget.notificationService,
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
                                        databaseService: _databaseService,
                                        notificationService:
                                            widget.notificationService,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                          Container(
                            height: 1,
                            color: CupertinoColors.opaqueSeparator
                                .withOpacity(0.2),
                          ),
                          FutureBuilder(
                            future: _databaseService.getGroupMessagesType(
                                group.id, Type.news),
                            builder: (context, snapshot) {
                              return Column(
                                children: [
                                  CupertinoListTile(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0),
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
                                        (snapshot.connectionState ==
                                                    ConnectionState.waiting ||
                                                snapshot.hasError ||
                                                snapshot.data!.isEmpty)
                                            ? const SizedBox()
                                            : Text(
                                                snapshot.data!.length
                                                    .toString(),
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.normal,
                                                  color: CupertinoColors
                                                      .opaqueSeparator,
                                                ),
                                              ),
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
                                          databaseService: _databaseService,
                                          notificationService:
                                              widget.notificationService,
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
                                            databaseService: _databaseService,
                                            notificationService:
                                                widget.notificationService,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                          Container(
                            height: 1,
                            color: CupertinoColors.opaqueSeparator
                                .withOpacity(0.2),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: NotificationWidget(
                                notify: notify,
                                notifyFunction: (value) {
                                  _databaseService.updateNotification(
                                      widget.group.id, value, true);
                                }),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                constraints: BoxConstraints(
                  maxHeight: (group.admin == uid)
                      ? (group.members!.length + 1) * 50
                      : group.members!.length * 50,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: CupertinoTheme.of(context).primaryContrastingColor,
                ),
                height: (group.admin == uid)
                    ? (group.members!.length + 1) * 50
                    : group.members!.length * 50,
                child: (group.admin == uid)
                    ? ListView(
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.of(context).push(
                                            CupertinoPageRoute(
                                              builder: (context) =>
                                                  AddMembersGroupPage(
                                                group: group,
                                              ),
                                            ),
                                          );
                                        },
                                        child: CupertinoListTile(
                                          leading: Transform.scale(
                                            scale: MediaQuery.of(context)
                                                        .size
                                                        .width >
                                                    Constants.limitWidth
                                                ? 1.3
                                                : 1,
                                            child: Icon(
                                              CupertinoIcons.person_add,
                                              size: 25,
                                              color: CupertinoTheme.of(context)
                                                  .primaryColor,
                                            ),
                                          ),
                                          title: Text(
                                            "Add Members",
                                            style: TextStyle(
                                                color:
                                                    CupertinoTheme.of(context)
                                                        .primaryColor,
                                                fontSize: MediaQuery.of(context)
                                                            .size
                                                            .width >
                                                        Constants.limitWidth
                                                    ? 20
                                                    : 15),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: 1,
                            color: CupertinoColors.opaqueSeparator
                                .withOpacity(0.2),
                          ),
                          memberList(),
                        ],
                      )
                    : memberList(),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  showLeaveGroupDialog(context);
                },
                child: const Text('Leave Group',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemRed,
                    ),
                    textAlign: TextAlign.center),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }

  Widget memberList() {
    return ListView.builder(
      primary: false,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: group.members!.length,
      itemBuilder: (context, index) {
        return FutureBuilder(
            future: _databaseService.getUserData(group.members![index]),
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

                return Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: UserTile(
                            user: userData,
                            isFollowing: null,
                          ),
                        ),
                        if (group.admin == userData.uid)
                          const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Text(
                              "Admin",
                              style: TextStyle(
                                color: CupertinoColors.systemGrey4,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    (index == group.members!.length - 1)
                        ? const SizedBox()
                        : Container(
                            height: 1,
                            color: CupertinoColors.opaqueSeparator
                                .withOpacity(0.2),
                          ),
                  ],
                );
              }
            });
      },
    );
  }

  void showLeaveGroupDialog(BuildContext context) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext newContext) {
        return CupertinoAlertDialog(
          title: const Text("Leave Group"),
          content: const Text("Are you sure you want to leave this group?"),
          actions: [
            CupertinoDialogAction(
              onPressed: () {
                Navigator.of(newContext).pop();
              },
              child: const Text("Cancel"),
            ),
            CupertinoDialogAction(
              onPressed: () async {
                Navigator.of(newContext).pop();
                BuildContext buildContext = context;
                showCupertinoDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext loadingContext) {
                    buildContext = loadingContext;
                    return const CupertinoAlertDialog(
                      content: CupertinoActivityIndicator(),
                    );
                  },
                );

                await _databaseService.toggleGroupJoin(
                  group.id,
                );
                if (!context.mounted) return;
                Navigator.of(buildContext).pop();
                if (widget.canNavigate) {
                  widget.navigateToPage!(const StartMessagingWidget());
                  return;
                }
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
