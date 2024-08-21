import 'dart:async';

import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chats/groups/create_group_page.dart';
import 'package:dima_project/pages/chats/groups/group_chat_page.dart';
import 'package:dima_project/pages/chats/groups/group_info_page.dart';
import 'package:dima_project/pages/chats/private_chats/private_chat_page.dart';
import 'package:dima_project/pages/chats/private_chats/private_info_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/widgets/chats/group_chat_tile_tablet.dart';
import 'package:dima_project/widgets/custom_selection_option_widget.dart';
import 'package:dima_project/widgets/chats/private_chat_tile_tablet.dart';
import 'package:dima_project/widgets/start_messaging_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';
import 'package:dima_project/services/notification_service.dart';

class ChatTabletPage extends StatefulWidget {
  final Group? selectedGroup;
  final PrivateChat? selectedPrivateChat;
  final UserData? selectedUser;
  final DatabaseService databaseService;
  final NotificationService notificationService;
  final ImagePicker imagePicker;
  final StorageService storageService;
  final EventService eventService;
  const ChatTabletPage({
    super.key,
    required this.selectedGroup,
    required this.selectedPrivateChat,
    required this.selectedUser,
    required this.databaseService,
    required this.notificationService,
    required this.imagePicker,
    required this.eventService,
    required this.storageService,
  });

  @override
  ChatTabletPageState createState() => ChatTabletPageState();
}

class ChatTabletPageState extends State<ChatTabletPage> {
  late final Stream<List<PrivateChat>> _privateChatsStream;
  late final Stream<List<Group>> _groupsStream;
  String searchedText = "";
  final String uid = AuthService.uid;
  Group? selectedGroup;
  UserData? selectedUser;
  PrivateChat? selectedPrivateChat;
  int idx = 0;
  Widget page = const StartMessagingWidget();
  late final DatabaseService _databaseService;
  @override
  void initState() {
    super.initState();
    _databaseService = widget.databaseService;
    _privateChatsStream = _databaseService.getPrivateChatsStream();
    _groupsStream = _databaseService.getGroupsStream();

    if (widget.selectedGroup != null) {
      setState(() {
        selectedGroup = widget.selectedGroup;
        page = GroupChatPage(
          eventService: widget.eventService,
          storageService: widget.storageService,
          group: selectedGroup!,
          key: UniqueKey(),
          navigateToPage: _navigateToPage,
          canNavigate: true,
          databaseService: _databaseService,
          notificationService: widget.notificationService,
          imagePicker: widget.imagePicker,
        );
      });
    }
    if (widget.selectedUser != null) {
      setState(() {
        idx = 1;
        selectedUser = widget.selectedUser;
        selectedPrivateChat = widget.selectedPrivateChat;
        page = PrivateChatPage(
          storageService: widget.storageService,
          privateChat: selectedPrivateChat!,
          key: UniqueKey(),
          navigateToPage: _navigateToPage,
          canNavigate: true,
          user: selectedUser!,
          databaseService: _databaseService,
          notificationService: widget.notificationService,
          imagePicker: widget.imagePicker,
        );
      });
    }
  }

  void _navigateToPage(Widget newPage) {
    setState(() {
      page = newPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: Row(
        children: [
          getListChats(),
          getChats(),
        ],
      ),
    );
  }

  Widget getChats() {
    return Align(
      alignment: Alignment.topRight,
      child:
          SizedBox(width: MediaQuery.of(context).size.width * 0.6, child: page),
    );
  }

  Widget getListChats() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width * 0.4,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10.0, top: 25.0),
                  child: Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: CupertinoTheme.of(context).primaryColor,
                    ),
                  ),
                ),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  borderRadius: BorderRadius.circular(30),
                  minSize: 30,
                  child: const Icon(CupertinoIcons.add),
                  onPressed: () {
                    _navigateToPage(CreateGroupPage(
                      canNavigate: true,
                      navigateToPage: _navigateToPage,
                      imagePicker: widget.imagePicker,
                    ));
                  },
                ),
              ],
            ),
            SizedBox(
              height: 50,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoSearchTextField(
                  onChanged: (value) {
                    setState(() {
                      searchedText = value;
                    });
                  },
                ),
              ),
            ),
            SizedBox(
              height: 50,
              child: CustomSelectionOption(
                initialIndex: idx,
                textLeft: "Groups",
                textRight: "Private",
                onChanged: (value) {
                  setState(() {
                    idx = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  groupList(),
                  privateChatList(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget groupList() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: StreamBuilder<List<Group>>(
        stream: _groupsStream,
        builder: (context, snapshot) {
          if (idx == 1) {
            return const SizedBox.shrink();
          }
          int i = 0;

          if (snapshot.hasData) {
            var data = snapshot.data!;
            if (data.isNotEmpty) {
              return ListView.builder(
                  shrinkWrap: true,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final group = data[index];
                    if (!group.name
                        .toLowerCase()
                        .contains(searchedText.toLowerCase())) {
                      i += 1;
                      if (i == data.length) {
                        return Center(
                            child: Column(
                          children: [
                            MediaQuery.of(context).platformBrightness ==
                                    Brightness.dark
                                ? Image.asset(
                                    'assets/darkMode/no_groups_chat_found.png')
                                : Image.asset(
                                    'assets/images/no_groups_chat_found.png'),
                            const Text('No groups found'),
                          ],
                        ));
                      }
                      return const SizedBox.shrink();
                    }

                    if (selectedGroup != null &&
                        selectedGroup!.id == group.id &&
                        (selectedGroup!.name != group.name ||
                            selectedGroup!.imagePath != group.imagePath ||
                            selectedGroup!.members!.length !=
                                group.members!.length)) {
                      selectedGroup = group;
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        setState(() {
                          if (page is GroupChatPage) {
                            page = GroupChatPage(
                              eventService: widget.eventService,
                              storageService: widget.storageService,
                              group: group,
                              key: UniqueKey(),
                              navigateToPage: _navigateToPage,
                              canNavigate: true,
                              databaseService: _databaseService,
                              notificationService: widget.notificationService,
                              imagePicker: widget.imagePicker,
                            );
                          }
                          if (page is GroupInfoPage) {
                            page = GroupInfoPage(
                              group: group,
                              key: UniqueKey(),
                              navigateToPage: _navigateToPage,
                              canNavigate: true,
                              databaseService: _databaseService,
                              notificationService: widget.notificationService,
                              imagePicker: widget.imagePicker,
                            );
                          }
                        });
                      });
                    }

                    if (group.lastMessage == null) {
                      return GroupChatTileTablet(
                        onDismissed: (DismissDirection direction) async {
                          await _databaseService.toggleGroupJoin(group.id);
                          setState(() {
                            if (selectedGroup != null &&
                                selectedGroup!.id == group.id) {
                              selectedGroup = null;
                              page = const StartMessagingWidget();
                            }
                          });
                        },
                        username: '',
                        group: group,
                        onPressed: (Group group) {
                          setState(() {
                            selectedGroup = group;
                            page = GroupChatPage(
                              eventService: widget.eventService,
                              storageService: widget.storageService,
                              group: group,
                              key: UniqueKey(),
                              navigateToPage: _navigateToPage,
                              canNavigate: true,
                              databaseService: _databaseService,
                              notificationService: widget.notificationService,
                              imagePicker: widget.imagePicker,
                            );
                          });
                        },
                      );
                    }
                    return StreamBuilder(
                        stream: _databaseService.getUserDataFromUID(
                            group.lastMessage!.recentMessageSender),
                        builder: (context, snapshot) {
                          String username = "";
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            username = "";
                          }
                          if (snapshot.hasError) {
                            username = "Deleted Account";
                          }
                          if (snapshot.hasData) {
                            username =
                                UserData.fromSnapshot(snapshot.data!).username;
                          }
                          return GroupChatTileTablet(
                            onDismissed: (DismissDirection direction) async {
                              await _databaseService.toggleGroupJoin(group.id);
                              setState(() {
                                if (selectedGroup != null &&
                                    selectedGroup!.id == group.id) {
                                  selectedGroup = null;
                                  page = const StartMessagingWidget();
                                }
                              });
                            },
                            group: group,
                            username: username,
                            onPressed: (Group group) {
                              setState(() {
                                selectedGroup = group;
                                group.lastMessage!.unreadMessages = 0;
                                page = GroupChatPage(
                                  eventService: widget.eventService,
                                  storageService: widget.storageService,
                                  group: group,
                                  key: UniqueKey(),
                                  navigateToPage: _navigateToPage,
                                  canNavigate: true,
                                  databaseService: _databaseService,
                                  notificationService:
                                      widget.notificationService,
                                  imagePicker: widget.imagePicker,
                                );
                              });
                            },
                          );
                        });
                  });
            } else {
              return noChatWidget();
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: CupertinoTheme.of(context).primaryContrastingColor,
              highlightColor:
                  CupertinoTheme.of(context).primaryContrastingColor,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width * 0.4,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget privateChatList() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: StreamBuilder<List<PrivateChat>>(
        stream: _privateChatsStream,
        builder: (context, snapshot) {
          if (idx == 0) {
            return const SizedBox.shrink();
          }
          if (snapshot.hasData) {
            bool found = false;
            var data = snapshot.data!;

            if (data.isNotEmpty) {
              return ListView.builder(
                shrinkWrap: true,
                itemCount: data.length,
                itemBuilder: (context, index) {
                  final privateChat = data[index];
                  if (privateChat.lastMessage == null) {
                    return const SizedBox();
                  }

                  return StreamBuilder(
                    stream: _databaseService.getUserDataFromUID(
                        privateChat.members[0] == uid
                            ? privateChat.members[1]
                            : privateChat.members[0]),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        final other = UserData.fromSnapshot(snapshot.data!);

                        if (!other.username
                            .toLowerCase()
                            .contains(searchedText.toLowerCase())) {
                          if (index == data.length - 1 && !found) {
                            return Center(
                                child: Column(
                              children: [
                                MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark
                                    ? Image.asset(
                                        'assets/darkMode/no_chat_found.png')
                                    : Image.asset(
                                        'assets/images/no_chat_found.png'),
                                const Text("No private chats found"),
                              ],
                            ));
                          }
                          return const SizedBox.shrink();
                        }
                        found = true;
                        if (selectedUser != null &&
                            selectedUser!.uid == other.uid &&
                            (selectedUser!.username != other.username ||
                                selectedUser!.imagePath != other.imagePath)) {
                          selectedUser = other;
                          selectedPrivateChat = privateChat;
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              if (page is PrivateChatPage) {
                                page = PrivateChatPage(
                                  storageService: widget.storageService,
                                  privateChat: privateChat,
                                  key: UniqueKey(),
                                  navigateToPage: _navigateToPage,
                                  canNavigate: true,
                                  user: other,
                                  databaseService: _databaseService,
                                  notificationService:
                                      widget.notificationService,
                                  imagePicker: widget.imagePicker,
                                );
                              }
                              if (page is PrivateInfoPage) {
                                page = PrivateInfoPage(
                                  privateChat: privateChat,
                                  key: UniqueKey(),
                                  navigateToPage: _navigateToPage,
                                  canNavigate: true,
                                  user: other,
                                  databaseService: _databaseService,
                                  notificationService:
                                      widget.notificationService,
                                );
                              }
                            });
                          });
                        }

                        return PrivateChatTileTablet(
                          onDismissed: (DismissDirection direction) async {
                            await _databaseService
                                .deletePrivateChat(privateChat);
                            setState(() {
                              if (selectedUser != null &&
                                  selectedUser!.uid == other.uid) {
                                selectedUser = null;
                                selectedPrivateChat = null;
                                page = const StartMessagingWidget();
                              }
                            });
                          },
                          onPressed: (PrivateChat privateChat) => {
                            setState(() {
                              selectedUser = other;
                              selectedPrivateChat = privateChat;
                              privateChat.lastMessage!.unreadMessages = 0;
                              page = PrivateChatPage(
                                storageService: widget.storageService,
                                privateChat: privateChat,
                                key: UniqueKey(),
                                navigateToPage: _navigateToPage,
                                canNavigate: true,
                                user: other,
                                databaseService: _databaseService,
                                notificationService: widget.notificationService,
                                imagePicker: widget.imagePicker,
                              );
                            })
                          },
                          privateChat: privateChat,
                          other: other,
                        );
                      } else {
                        if (snapshot.hasError) {
                          if (!("Deleted Account")
                              .toLowerCase()
                              .contains(searchedText.toLowerCase())) {
                            if (index == data.length - 1 && !found) {
                              return Center(
                                  child: Column(
                                children: [
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? Image.asset(
                                          'assets/darkMode/no_chat_found.png')
                                      : Image.asset(
                                          'assets/images/no_chat_found.png'),
                                  const Text('No private chats found'),
                                ],
                              ));
                            }
                            return const SizedBox.shrink();
                          }
                          return PrivateChatTileTablet(
                            onDismissed: (DismissDirection direction) async {
                              await _databaseService
                                  .deletePrivateChat(privateChat);

                              setState(() {
                                if (selectedPrivateChat != null &&
                                    selectedPrivateChat!.id == privateChat.id) {
                                  selectedUser = null;
                                  selectedPrivateChat = null;
                                  page = const StartMessagingWidget();
                                }
                              });
                            },
                            onPressed: (PrivateChat privateChat) => {
                              setState(() {
                                selectedUser = null;
                                selectedPrivateChat = privateChat;
                                privateChat.lastMessage!.unreadMessages = 0;
                                page = PrivateChatPage(
                                  storageService: widget.storageService,
                                  databaseService: _databaseService,
                                  notificationService:
                                      widget.notificationService,
                                  imagePicker: widget.imagePicker,
                                  privateChat: privateChat,
                                  key: UniqueKey(),
                                  navigateToPage: _navigateToPage,
                                  canNavigate: true,
                                  user: UserData(
                                    imagePath: '',
                                    username: 'Deleted Account',
                                    categories: [],
                                    email: '',
                                    name: '',
                                    surname: '',
                                  ),
                                );
                              })
                            },
                            other: UserData(
                              imagePath: '',
                              username: 'Deleted Account',
                              categories: [],
                              email: '',
                              name: '',
                              surname: '',
                            ),
                            privateChat: privateChat,
                          );
                        }
                        return Container();
                      }
                    },
                  );
                },
              );
            } else {
              return noChatWidget();
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return Shimmer.fromColors(
              baseColor: CupertinoTheme.of(context).primaryContrastingColor,
              highlightColor:
                  CupertinoTheme.of(context).primaryContrastingColor,
              child: Container(
                height: MediaQuery.of(context).size.height * 0.8,
                width: MediaQuery.of(context).size.width * 0.4,
                color: CupertinoTheme.of(context).primaryColor,
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Widget noChatWidget() {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            idx == 0
                ? MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Image.asset(
                        'assets/darkMode/search_groups_chat.png',
                      )
                    : Image.asset(
                        'assets/images/search_groups_chat.png',
                      )
                : MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Image.asset(
                        'assets/darkMode/search_chat.png',
                      )
                    : Image.asset(
                        'assets/images/search_chat.png',
                      ),
            Text(
              "No ${idx == 0 ? "groups" : "chats"} yet",
              style: const TextStyle(
                color: CupertinoColors.systemGrey,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              idx == 0
                  ? "Create a group to start chatting"
                  : "Create a chat to start chatting",
              style: const TextStyle(
                  color: CupertinoColors.systemGrey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }
}
