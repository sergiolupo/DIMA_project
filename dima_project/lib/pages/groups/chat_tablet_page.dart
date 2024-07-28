import 'dart:async';

import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/groups/create_group_page.dart';
import 'package:dima_project/pages/groups/group_chat_page.dart';
import 'package:dima_project/pages/groups/group_info_page.dart';
import 'package:dima_project/pages/private_chat_page.dart';
import 'package:dima_project/pages/private_info_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/group_chat_tile_tablet.dart';
import 'package:dima_project/widgets/home/selectoption_widget.dart';
import 'package:dima_project/widgets/private_chat_tile_tablet.dart';
import 'package:flutter/cupertino.dart';

class ChatTabletPage extends StatefulWidget {
  const ChatTabletPage({
    super.key,
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
  Widget page = const SizedBox.shrink();
  @override
  void initState() {
    super.initState();
    _privateChatsStream = DatabaseService.getPrivateChatsStream();
    _groupsStream = DatabaseService.getGroupsStream();
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
              child: CustomSelectOption(
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

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
                            const Text('No groups'),
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
                              group: group,
                              key: UniqueKey(),
                              navigateToPage: _navigateToPage,
                              canNavigate: true,
                            );
                          }
                          if (page is GroupInfoPage) {
                            page = GroupInfoPage(
                              group: group,
                              key: UniqueKey(),
                              navigateToPage: _navigateToPage,
                              canNavigate: true,
                            );
                          }
                        });
                      });
                    }

                    if (group.lastMessage == null) {
                      return GroupChatTileTablet(
                        onDismissed: (DismissDirection direction) async {
                          await DatabaseService.toggleGroupJoin(group.id);
                          setState(() {
                            if (selectedGroup != null &&
                                selectedGroup!.id == group.id) {
                              selectedGroup = null;
                              page = const SizedBox.shrink();
                            }
                          });
                        },
                        username: '',
                        group: group,
                        onPressed: (Group group) {
                          setState(() {
                            selectedGroup = group;
                            page = GroupChatPage(
                              group: group,
                              key: UniqueKey(),
                              navigateToPage: _navigateToPage,
                              canNavigate: true,
                            );
                          });
                        },
                      );
                    }
                    return StreamBuilder(
                        stream: DatabaseService.getUserDataFromUID(
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
                            username = snapshot.data!.username;
                          }
                          return GroupChatTileTablet(
                            onDismissed: (DismissDirection direction) async {
                              await DatabaseService.toggleGroupJoin(group.id);
                              setState(() {
                                if (selectedGroup != null &&
                                    selectedGroup!.id == group.id) {
                                  selectedGroup = null;
                                  page = const SizedBox.shrink();
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
                                  group: group,
                                  key: UniqueKey(),
                                  navigateToPage: _navigateToPage,
                                  canNavigate: true,
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
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          } else {
            return Container(); // Return an empty container or handle other cases as needed
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
          int i = 0;
          if (snapshot.hasData) {
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

                  return StreamBuilder<UserData>(
                    stream: DatabaseService.getUserDataFromUID(
                        privateChat.members[0] == uid
                            ? privateChat.members[1]
                            : privateChat.members[0]),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CupertinoActivityIndicator(),
                        );
                      }

                      if (snapshot.hasData) {
                        final other = snapshot.data!;

                        if (!other.username
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
                                        'assets/darkMode/no_chat_found.png')
                                    : Image.asset(
                                        'assets/images/no_chat_found.png'),
                                const Text('No private chats'),
                              ],
                            ));
                          }
                          return const SizedBox.shrink();
                        }

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
                                  privateChat: privateChat,
                                  key: UniqueKey(),
                                  navigateToPage: _navigateToPage,
                                  canNavigate: true,
                                  user: other,
                                );
                              }
                              if (page is PrivateInfoPage) {
                                page = PrivateInfoPage(
                                  privateChat: privateChat,
                                  key: UniqueKey(),
                                  navigateToPage: _navigateToPage,
                                  canNavigate: true,
                                  user: other,
                                );
                              }
                            });
                          });
                        }

                        return PrivateChatTileTablet(
                          onDismissed: (DismissDirection direction) async {
                            await DatabaseService.deletePrivateChat(
                                privateChat);
                            setState(() {
                              if (selectedUser != null &&
                                  selectedUser!.uid == other.uid) {
                                selectedUser = null;
                                selectedPrivateChat = null;
                                page = const SizedBox.shrink();
                              }
                            });
                          },
                          onPressed: (PrivateChat privateChat) => {
                            setState(() {
                              selectedUser = other;
                              selectedPrivateChat = privateChat;
                              privateChat.lastMessage!.unreadMessages = 0;
                              page = PrivateChatPage(
                                privateChat: privateChat,
                                key: UniqueKey(),
                                navigateToPage: _navigateToPage,
                                canNavigate: true,
                                user: other,
                              );
                            })
                          },
                          privateChat: privateChat,
                          other: other,
                        );
                      } else {
                        if (snapshot.hasError) {
                          return PrivateChatTileTablet(
                            onDismissed: (DismissDirection direction) async {
                              await DatabaseService.deletePrivateChat(
                                  privateChat);

                              setState(() {
                                if (selectedPrivateChat != null &&
                                    selectedPrivateChat!.id == privateChat.id) {
                                  selectedUser = null;
                                  selectedPrivateChat = null;
                                  page = const SizedBox.shrink();
                                }
                              });
                            },
                            onPressed: (PrivateChat privateChat) => {
                              setState(() {
                                selectedUser = null;
                                selectedPrivateChat = privateChat;
                                privateChat.lastMessage!.unreadMessages = 0;
                                page = PrivateChatPage(
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
                        return Container(); // Return an empty container or handle other cases as needed
                      }
                    },
                  );
                },
              );
            } else {
              return noChatWidget();
            }
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          } else {
            return Container(); // Return an empty container or handle other cases as needed
          }
        },
      ),
    );
  }

  Widget noChatWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          idx == 0
              ? MediaQuery.of(context).platformBrightness == Brightness.dark
                  ? Image.asset(
                      'assets/darkMode/search_chat.png',
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
                ? "Create a group to start chatting "
                : "Start a private chat to start chatting",
            style: const TextStyle(
                color: CupertinoColors.systemGrey, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
