import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
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
  Stream<List<Message>>? chats;

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
      chats = DatabaseService.getChats(widget.group!.id, widget.user.username);
    } else {
      chats = DatabaseService.getPrivateChats(
          privateChat!.user, privateChat!.visitor);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Column(children: [
          privateChat == null
              ? Text(widget.group!.name, style: const TextStyle(fontSize: 10))
              : Text(privateChat!.user, style: const TextStyle(fontSize: 10)),
          privateChat != null
              ? StreamBuilder(
                  stream: DatabaseService.getUserInfo(widget.privateChat!.user),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final data = snapshot.data?.docs;
                      final list =
                          data?.map((e) => UserData.fromSnapshot(e)).toList();
                      final user = list![0];
                      return user.online == true
                          ? const Text("Online", style: TextStyle(fontSize: 10))
                          : Text(
                              DateUtil.getLastSeenTime(
                                  context: context,
                                  time: user.lastSeen!.microsecondsSinceEpoch
                                      .toString()),
                              style: const TextStyle(fontSize: 10));
                    } else {
                      return Container();
                    }
                  })
              : Container(),
        ]),
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
    return StreamBuilder<List<Message>>(
      stream: chats,
      builder: (context, snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final message = snapshot.data![index];
                  return MessageTile(
                    username: widget.user.username,
                    message: message,
                  );
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
        if (privateChat!.id == null) {
          await DatabaseService.createPrivateChat(privateChat!);
          chats = DatabaseService.getPrivateChats(
              privateChat!.user, privateChat!.visitor);
        }
        privateChat = await DatabaseService.getPrivateChatsFromMember(
            privateChat!.visitor, privateChat!.user);
        DatabaseService.sendMessage(privateChat!.id!, message);
      }
      setState(() {
        messageEditingController.clear();
      });
    }
  }
}
