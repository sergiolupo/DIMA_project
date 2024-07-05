import 'dart:async';

import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/groups/create_group_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/group_chat_tile.dart';
import 'package:dima_project/widgets/home/selectoption_widget.dart';
import 'package:dima_project/widgets/private_chat_tile.dart';
import 'package:flutter/cupertino.dart';

class ListChatPage extends StatefulWidget {
  final String uuid;
  const ListChatPage({super.key, required this.uuid});

  @override
  ListChatPageState createState() => ListChatPageState();
}

class ListChatPageState extends State<ListChatPage> {
  Stream<List<PrivateChat>>? _privateChatsStream;
  Stream<List<Group>>? _groupsStream;

  String groupName = "";
  int idx = 0;
  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    _privateChatsStream = DatabaseService.getPrivateChatsStream();
    _groupsStream = DatabaseService.getGroupsStream(widget.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return (_groupsStream == null || _privateChatsStream == null)
        ? const CupertinoPageScaffold(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          )
        : MediaQuery(
            data: MediaQuery.of(context),
            child: CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                backgroundColor: CupertinoTheme.of(context).primaryColor,
                middle: const Text(
                  "Chat",
                  style: TextStyle(
                    color: CupertinoColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 27,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Column(
                  children: [
                    CustomSelectOption(
                      textLeft: "Groups",
                      textRight: "Private",
                      onChanged: (value) {
                        setState(() {
                          idx = value;
                          //print({"INDICE: $idx"});
                          _subscribe();
                        });
                      },
                    ),
                    Stack(
                      children: [
                        groupList(),
                        privateChatList(),
                        Positioned(
                          bottom: 50,
                          right: 20,
                          child: CupertinoButton(
                            onPressed: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) =>
                                          CreateGroupPage(uuid: widget.uuid)));
                            },
                            child: const Icon(CupertinoIcons.add, size: 30),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  Widget groupList() {
    return Visibility(
      visible: idx == 0,
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: StreamBuilder<List<Group>>(
          stream: _groupsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CupertinoActivityIndicator(),
              );
            }

            if (snapshot.hasData) {
              var data = snapshot.data!;
              if (data.isNotEmpty) {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final group = data[index];

                    if (group.lastMessage == null) {
                      return GroupChatTile(
                        uuid: widget.uuid,
                        group: group,
                        lastMessage: null,
                      );
                    }
                    return StreamBuilder<UserData>(
                      stream: DatabaseService.getUserDataFromUUID(
                          group.lastMessage!.recentMessageSender),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CupertinoActivityIndicator(),
                          );
                        }
                        if (snapshot.hasData) {
                          final user = snapshot.data!;
                          bool sentByMe = user.uuid == widget.uuid;
                          return GroupChatTile(
                            uuid: widget.uuid,
                            group: group,
                            lastMessage: LastMessage(
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(idx == 0 ? CupertinoIcons.group : CupertinoIcons.person,
              size: 100, color: CupertinoColors.systemGrey),
          const SizedBox(height: 20),
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

  Widget privateChatList() {
    return Visibility(
      visible: idx == 1,
      child: SizedBox(
        height: MediaQuery.of(context).size.height - 200,
        child: StreamBuilder<List<PrivateChat>>(
          stream: _privateChatsStream,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              var data = snapshot.data!;

              if (data.isNotEmpty) {
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final privateChat = data[index];
                    if (privateChat.lastMessage == null) {
                      return const SizedBox();
                    }

                    return StreamBuilder<UserData>(
                      stream: DatabaseService.getUserDataFromUUID(
                          privateChat.lastMessage!.recentMessageSender),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CupertinoActivityIndicator(),
                          );
                        }
                        if (snapshot.hasData) {
                          final user = snapshot.data!;
                          bool sentByMe = user.uuid == widget.uuid;
                          return PrivateChatTile(
                            uuid: widget.uuid,
                            privateChat: privateChat,
                            lastMessage: LastMessage(
                              recentMessage:
                                  privateChat.lastMessage!.recentMessage,
                              recentMessageSender: user.username,
                              recentMessageTimestamp: privateChat
                                  .lastMessage!.recentMessageTimestamp,
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
}
