import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/message_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

class ChatPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final String username;
  const ChatPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.username,
  });

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  Stream<QuerySnapshot>? chats;
  TextEditingController messageEditingController = TextEditingController();
  String admin = "";
  @override
  void initState() {
    getChatAndAdmin();
    super.initState();
  }

  getChatAndAdmin() async {
    DatabaseService.getChats(widget.groupId).then((val) {
      setState(() {
        chats = val;
      });
    });
    DatabaseService.getGroupAdmin(widget.groupId).then((val) {
      setState(() {
        admin = val;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(widget.groupName),
        backgroundColor: CupertinoTheme.of(context).primaryColor,
        trailing: CupertinoButton(
          onPressed: () {
            context.go("/groupinfo", extra: {
              "groupId": widget.groupId,
              "groupName": widget.groupName,
              "admin": admin,
            });
          },
          child: const Icon(CupertinoIcons.info),
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
      DatabaseService.sendMessage(widget.groupId, chatMessageMap);
      setState(() {
        messageEditingController.clear();
      });
    }
  }
}
