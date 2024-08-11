import 'dart:async';

import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chats/groups/create_group_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/widgets/chats/group_chat_tile.dart';
import 'package:dima_project/widgets/custom_selection_option_widget.dart';
import 'package:dima_project/widgets/chats/private_chat_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:shimmer/shimmer.dart';

class ChatPage extends StatefulWidget {
  final DatabaseService databaseService;
  final NotificationService notificationService;
  const ChatPage({
    super.key,
    required this.databaseService,
    required this.notificationService,
  });

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  late final Stream<List<PrivateChat>> _privateChatsStream;
  late final Stream<List<Group>> _groupsStream;
  final String uid = AuthService.uid;
  String searchedText = "";
  int idx = 0;
  late final DatabaseService _databaseService;
  @override
  void initState() {
    super.initState();
    _databaseService = widget.databaseService;
    _privateChatsStream = _databaseService.getPrivateChatsStream();
    _groupsStream = _databaseService.getGroupsStream();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
      navigationBar: CupertinoNavigationBar(
        transitionBetweenRoutes: false,
        trailing: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => const CreateGroupPage(
                          canNavigate: false,
                        )));
          },
          child: const Icon(
            CupertinoIcons.add_circled_solid,
            size: 30,
          ),
        ),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        middle: Text(
          "Chats",
          style: TextStyle(
            color: CupertinoTheme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
            fontSize: 25,
          ),
        ),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              onChanged: (value) {
                setState(() {
                  searchedText = value;
                });
              },
            ),
          ),
          CustomSelectionOption(
            textLeft: "Groups",
            textRight: "Private",
            onChanged: (value) {
              setState(() {
                idx = value;
              });
            },
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
                  if (group.lastMessage == null) {
                    return GroupChatTile(
                      username: '',
                      group: group,
                      databaseService: _databaseService,
                      notificationService: widget.notificationService,
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
                        return GroupChatTile(
                          group: group,
                          username: username,
                          databaseService: _databaseService,
                          notificationService: widget.notificationService,
                        );
                      });
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

  Widget privateChatList() {
    return SizedBox(
      height: MediaQuery.of(context).size.height,
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
                                const Text('No private chats found'),
                              ],
                            ));
                          }
                          return const SizedBox.shrink();
                        }
                        return PrivateChatTile(
                          privateChat: privateChat,
                          other: other,
                          databaseService: _databaseService,
                          notificationService: widget.notificationService,
                        );
                      } else {
                        if (snapshot.hasError) {
                          if (!("Deleted Account")
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
                                  const Text('No private chats found'),
                                ],
                              ));
                            }
                            return const SizedBox.shrink();
                          }
                          return PrivateChatTile(
                            privateChat: privateChat,
                            other: UserData(
                              imagePath: '',
                              username: 'Deleted Account',
                              categories: [],
                              email: '',
                              name: '',
                              surname: '',
                            ),
                            databaseService: _databaseService,
                            notificationService: widget.notificationService,
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
}
