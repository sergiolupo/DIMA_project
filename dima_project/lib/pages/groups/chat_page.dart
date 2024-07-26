import 'dart:async';

import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/groups/create_group_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/group_chat_tile.dart';
import 'package:dima_project/widgets/home/selectoption_widget.dart';
import 'package:dima_project/widgets/private_chat_tile.dart';
import 'package:flutter/cupertino.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    super.key,
  });

  @override
  ListChatPageState createState() => ListChatPageState();
}

class ListChatPageState extends State<ChatPage> {
  Stream<List<PrivateChat>>? _privateChatsStream;
  Stream<List<Group>>? _groupsStream;
  final String uid = AuthService.uid;
  String searchedText = "";
  int idx = 0;
  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    _privateChatsStream = DatabaseService.getPrivateChatsStream();
    _groupsStream = DatabaseService.getGroupsStream();
  }

  @override
  Widget build(BuildContext context) {
    return (_groupsStream == null || _privateChatsStream == null)
        ? const CupertinoPageScaffold(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          )
        : CupertinoPageScaffold(
            backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
            navigationBar: CupertinoNavigationBar(
              transitionBetweenRoutes: false,
              trailing: CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const CreateGroupPage()));
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
                CustomSelectOption(
                  textLeft: "Groups",
                  textRight: "Private",
                  onChanged: (value) {
                    setState(() {
                      idx = value;
                      _subscribe();
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
    return Visibility(
      visible: idx == 0,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<List<Group>>(
          stream: _groupsStream,
          builder: (context, snapshot) {
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
                    if (group.lastMessage == null) {
                      return GroupChatTile(
                        group: group,
                        lastMessage: null,
                      );
                    }
                    return StreamBuilder<UserData>(
                      stream: DatabaseService.getUserDataFromUID(
                          group.lastMessage!.recentMessageSender),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CupertinoActivityIndicator(),
                          );
                        }
                        if (snapshot.hasError) {
                          return GroupChatTile(
                            group: group,
                            lastMessage: LastMessage(
                              recentMessageType:
                                  group.lastMessage!.recentMessageType,
                              recentMessage: group.lastMessage!.recentMessage,
                              recentMessageSender: 'Deleted Account',
                              recentMessageTimestamp:
                                  group.lastMessage!.recentMessageTimestamp,
                              sentByMe: false,
                            ),
                          );
                        }
                        if (snapshot.hasData) {
                          final user = snapshot.data!;
                          bool sentByMe = user.uid == uid;
                          return GroupChatTile(
                            group: group,
                            lastMessage: LastMessage(
                              recentMessageType:
                                  group.lastMessage!.recentMessageType,
                              recentMessage: group.lastMessage!.recentMessage,
                              recentMessageSender: user.username,
                              recentMessageTimestamp:
                                  group.lastMessage!.recentMessageTimestamp,
                              sentByMe: sentByMe,
                            ),
                          );
                        } else {
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
                  ? "Create a group to start chatting "
                  : "Start a private chat to start chatting",
              style: const TextStyle(
                  color: CupertinoColors.systemGrey, fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget privateChatList() {
    return Visibility(
      visible: idx == 1,
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: StreamBuilder<List<PrivateChat>>(
          stream: _privateChatsStream,
          builder: (context, snapshot) {
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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

                          bool sentByMe =
                              privateChat.lastMessage!.recentMessageSender ==
                                  uid;
                          return PrivateChatTile(
                            privateChat: privateChat,
                            other: other,
                            lastMessage: LastMessage(
                              recentMessageType:
                                  privateChat.lastMessage!.recentMessageType,
                              recentMessage:
                                  privateChat.lastMessage!.recentMessage,
                              recentMessageSender:
                                  sentByMe ? '' : other.username,
                              recentMessageTimestamp: privateChat
                                  .lastMessage!.recentMessageTimestamp,
                              sentByMe: sentByMe,
                            ),
                          );
                        } else {
                          if (snapshot.hasError) {
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
                              lastMessage: LastMessage(
                                recentMessageType:
                                    privateChat.lastMessage!.recentMessageType,
                                recentMessage:
                                    privateChat.lastMessage!.recentMessage,
                                recentMessageSender: privateChat
                                            .lastMessage!.recentMessageSender ==
                                        uid
                                    ? ''
                                    : 'Deleted Account',
                                recentMessageTimestamp: privateChat
                                    .lastMessage!.recentMessageTimestamp,
                                sentByMe: privateChat
                                            .lastMessage!.recentMessageSender ==
                                        uid
                                    ? true
                                    : false,
                              ),
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
      ),
    );
  }
}
