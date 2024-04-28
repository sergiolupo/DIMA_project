import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/message_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class ChatPage extends StatefulWidget {
  final Group? group;
  final UserData user;
  final PrivateChat? privateChat;
  const ChatPage({
    super.key,
    this.group,
    required this.user,
    this.privateChat,
  });

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageEditingController = TextEditingController();
  PrivateChat? privateChat;
  @override
  void initState() {
    privateChat = widget.privateChat;
    getChats();
    super.initState();
  }

  getChats() async {
    if (privateChat == null) {
      DatabaseService.getChats(widget.group!.id).then((val) {
        setState(() {
          chats = val;
        });
      });
    } else {
      DatabaseService.getPrivateChats(privateChat!.user, privateChat!.visitor)
          .then((val) {
        setState(() {
          chats = val;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: privateChat == null
            ? Text(widget.group!.name, style: const TextStyle(fontSize: 20))
            : Text(privateChat!.user, style: const TextStyle(fontSize: 20)),
        backgroundColor: CupertinoTheme.of(context).primaryColor,
        leading: CupertinoButton(
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go("/home", extra: 1);
            }
          },
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
        ),
        trailing: privateChat == null
            ? CupertinoButton(
                onPressed: () {
                  context.go(
                    "/groupinfo",
                    extra: {"group": widget.group, "user": widget.user},
                  );
                },
                child: const Icon(
                  CupertinoIcons.info,
                  color: CupertinoColors.white,
                ),
              )
            : null,
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: chatMessages(),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      color: CupertinoColors.inactiveGray,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: messageEditingController,
              style: const TextStyle(color: CupertinoColors.white),
              placeholder: "Type a message...",
              placeholderStyle: const TextStyle(color: CupertinoColors.white),
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.white),
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              sendMessage();
            },
            child: const Icon(CupertinoIcons.paperplane_fill,
                color: CupertinoColors.white),
          ),
        ],
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: chats,
      builder: (context, AsyncSnapshot snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                      username: widget.user.username,
                      message: Message(
                        content: snapshot.data.docs[index]["content"],
                        sender: snapshot.data.docs[index]["sender"],
                        sentByMe: widget.group != null
                            ? (widget.user.username ==
                                snapshot.data.docs[index]["sender"])
                            : privateChat!.visitor ==
                                snapshot.data.docs[index]["sender"],
                        senderImage: snapshot.data.docs[index]["senderImage"],
                        isGroupMessage: snapshot.data.docs[index]
                            ["isGroupMessage"],
                        time: snapshot.data.docs[index]["time"],
                        id: snapshot.data.docs[index].id,
                        readBy: (snapshot.data.docs[index]['readBy']
                                as List<dynamic>)
                            .map((readBy) => ReadBy(
                                  username: readBy['username'],
                                  readAt: readBy['readAt'],
                                ))
                            .toList()
                            .cast<ReadBy>(),
                        chatID: privateChat == null
                            ? widget.group!.id
                            : privateChat!.id,
                      ));
                },
              )
            : Container();
      },
    );
  }

  void sendMessage() async {
    if (messageEditingController.text.isNotEmpty) {
      Message message = Message(
          content: messageEditingController.text,
          sender:
              privateChat == null ? widget.user.username : privateChat!.visitor,
          receiver: privateChat == null ? "" : privateChat!.user,
          isGroupMessage: privateChat == null ? true : false,
          time: Timestamp.now(),
          senderImage: await DatabaseService.getUserImage(
              FirebaseAuth.instance.currentUser!.uid),
          readBy: []);

      if (privateChat == null) {
        DatabaseService.sendMessage(widget.group!.id, message);
      } else {
        if (chats == null) {
          await DatabaseService.createPrivateChat(privateChat!);
        }
        privateChat = await DatabaseService.getPrivateChatsFromMember(
            privateChat!.visitor, privateChat!.user);
        debugPrint("privateChat: ${privateChat!.id}");
        DatabaseService.sendMessage(privateChat!.id!, message);
      }
      setState(() {
        messageEditingController.clear();
        if (privateChat != null && chats == null) {
          DatabaseService.getPrivateChats(
                  privateChat!.user, privateChat!.visitor)
              .then((val) {
            setState(() {
              chats = val;
            });
          });
        }
      });
    }
  }
}
