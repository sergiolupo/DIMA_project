import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/message_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class ChatPage extends StatefulWidget {
  final Group group;
  final String username;
  const ChatPage({
    super.key,
    required this.group,
    required this.username,
  });

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageEditingController = TextEditingController();
  @override
  void initState() {
    getChats();
    super.initState();
  }

  getChats() async {
    DatabaseService.getChats(widget.group.id).then((val) {
      setState(() {
        chats = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.group.name, style: const TextStyle(fontSize: 20)),
        backgroundColor: CupertinoTheme.of(context).primaryColor,
        leading: CupertinoButton(
          onPressed: () {
            context.go("/home", extra: 1);
          },
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
        ),
        trailing: CupertinoButton(
          onPressed: () {
            context.go(
              "/groupinfo",
              extra: {"group": widget.group, "username": widget.username},
            );
          },
          child: const Icon(
            CupertinoIcons.info,
            color: CupertinoColors.white,
          ),
        ),
      ),
      child: Stack(
        children: <Widget>[
          chatMessages(),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              color: CupertinoColors.inactiveGray,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: Row(
                children: [
                  Expanded(
                    child: CupertinoTextField(
                      controller: messageEditingController,
                      style: const TextStyle(color: CupertinoColors.white),
                      placeholder: "Type a message...",
                      placeholderStyle:
                          const TextStyle(color: CupertinoColors.white),
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
            ),
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
                itemCount: snapshot.data.docs.length,
                itemBuilder: (context, index) {
                  return MessageTile(
                    message: snapshot.data.docs[index]["message"],
                    sender: snapshot.data.docs[index]["sender"],
                    sentByMe:
                        widget.username == snapshot.data.docs[index]["sender"],
                  );
                },
              )
            : Container();
      },
    );
  }

  void sendMessage() {
    if (messageEditingController.text.isNotEmpty) {
      Map<String, dynamic> chatMessageMap = {
        "message": messageEditingController.text,
        "sender": widget.username,
        "time": DateTime.now().millisecondsSinceEpoch,
      };
      DatabaseService.sendMessage(widget.group.id, chatMessageMap);
      setState(() {
        messageEditingController.clear();
      });
    }
  }
}
