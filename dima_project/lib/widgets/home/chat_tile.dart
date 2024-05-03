import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chat_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class ChatTile extends StatefulWidget {
  final UserData user;
  final Group? group;
  final PrivateChat? privateChat;
  final LastMessage? lastMessage;
  const ChatTile(
      {super.key,
      required this.user,
      this.group,
      this.privateChat,
      required this.lastMessage});

  @override
  ChatTileState createState() => ChatTileState();
}

class ChatTileState extends State<ChatTile> {
  UserData? _user;
  Stream<int>? unreadMessagesStream;
  @override
  void initState() {
    super.initState();
    if (widget.privateChat != null) {
      getUserData();
      unreadMessagesStream = DatabaseService.getUnreadMessages(
          false, widget.privateChat!.id!, widget.user.username);
    } else {
      unreadMessagesStream = DatabaseService.getUnreadMessages(
          true, widget.group!.id, widget.user.username);
    }
  }

  getUserData() async {
    await DatabaseService.getUserDataFromUsername(widget.privateChat!.user)
        .then((value) => setState(() {
              _user = value;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context, rootNavigator: true).push(
          CupertinoPageRoute(
            builder: (context) => ChatPage(
              user: widget.user,
              group: widget.group,
              privateChat: widget.privateChat,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 24, // Adjust padding based on screen width
          vertical: 16,
        ),
        child: CupertinoListTile(
          leading: widget.group != null
              ? CreateImageWidget.getGroupImage(widget.group!.imagePath!)
              : (_user != null)
                  ? CreateImageWidget.getUserImage(_user!.imagePath!)
                  : const SizedBox(),
          title: Text(
            widget.group == null
                ? widget.privateChat!.user
                : widget.group!.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: (widget.lastMessage != null)
              ? Text(
                  widget.lastMessage!.recentMessageSender ==
                          widget.user.username
                      ? "You: ${widget.lastMessage!.recentMessage}"
                      : "${widget.lastMessage!.recentMessageSender}: ${widget.lastMessage!.recentMessage}",
                  overflow: TextOverflow.ellipsis,
                )
              : Text("Join the conversation as ${widget.user.username}"),
          trailing: (widget.lastMessage != null)
              ? Column(
                  children: [
                    Text(
                      DateUtil.getFormattedTime(
                          context: context,
                          time: widget.lastMessage!.recentMessageTimestamp
                              .microsecondsSinceEpoch
                              .toString()),
                      style: const TextStyle(fontSize: 12),
                    ),
                    StreamBuilder(
                        stream: unreadMessagesStream,
                        builder: (context, snapshot) {
                          if (snapshot.hasData && snapshot.data != 0) {
                            return Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: CupertinoTheme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Text(
                                snapshot.data.toString(),
                                style: const TextStyle(
                                  color: CupertinoColors.white,
                                  fontSize: 12,
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox();
                          }
                        }),
                  ],
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}
