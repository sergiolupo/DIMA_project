import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/groups/group_chat_page.dart';
import 'package:dima_project/pages/private_chat_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class ChatTile extends StatefulWidget {
  final String uuid;
  final Group? group;
  final PrivateChat? privateChat;
  final LastMessage? lastMessage;
  const ChatTile(
      {super.key,
      required this.uuid,
      this.group,
      this.privateChat,
      required this.lastMessage});

  @override
  ChatTileState createState() => ChatTileState();
}

class ChatTileState extends State<ChatTile> {
  UserData? _other;
  Stream<int>? unreadMessagesStream;
  @override
  void initState() {
    super.initState();

    if (widget.privateChat != null) {
      getUserData();
      unreadMessagesStream = DatabaseService.getUnreadMessages(
          false, widget.privateChat!.id!, widget.uuid);
    } else {
      unreadMessagesStream = DatabaseService.getUnreadMessages(
          true, widget.group!.id, widget.uuid);
    }
  }

  getUserData() async {
    await DatabaseService.getUserData(
            widget.privateChat!.members[0] == widget.uuid
                ? widget.privateChat!.members[1]
                : widget.privateChat!.members[0])
        .then((value) => setState(() {
              _other = value;
            }));
  }

  @override
  Widget build(BuildContext context) {
    return (_other == null && widget.privateChat != null)
        ? const SizedBox()
        : GestureDetector(
            onTap: () {
              if (widget.privateChat != null) {
                Navigator.of(context, rootNavigator: true).push(
                  CupertinoPageRoute(
                    builder: (context) => PrivateChatPage(
                      uuid: widget.uuid,
                      privateChat: widget.privateChat!,
                    ),
                  ),
                );
              } else {
                Navigator.of(context, rootNavigator: true).push(
                  CupertinoPageRoute(
                    builder: (context) => GroupChatPage(
                      uuid: widget.uuid,
                      group: widget.group,
                    ),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24, // Adjust padding based on screen width
                vertical: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      widget.group != null
                          ? CreateImageWidget.getGroupImage(
                              widget.group!.imagePath!,
                              small: true)
                          : (_other != null)
                              ? CreateImageWidget.getUserImage(
                                  _other!.imagePath!,
                                  small: true)
                              : const SizedBox(),
                      const SizedBox(width: 16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.group == null
                                ? _other!.username
                                : widget.group!.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          const SizedBox(height: 2),
                          (widget.lastMessage != null)
                              ? Text(
                                  widget.lastMessage!.recentMessageSender ==
                                          widget.uuid
                                      ? "You: ${widget.lastMessage!.recentMessage}"
                                      : "${widget.lastMessage!.recentMessageSender}: ${widget.lastMessage!.recentMessage}",
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.inactiveGray,
                                  ),
                                )
                              : const Text(
                                  "Join the conversation!",
                                  style: TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.inactiveGray),
                                ),
                        ],
                      ),
                    ],
                  ),
                  (widget.lastMessage != null)
                      ? StreamBuilder(
                          stream: unreadMessagesStream,
                          builder: (context, snapshot) => StreamBuilder(
                            stream: unreadMessagesStream,
                            builder: (context, snapshot) {
                              final bool hasUnreadMessages =
                                  snapshot.hasData && snapshot.data != 0;
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    DateUtil.getFormattedTime(
                                      context: context,
                                      time: widget
                                          .lastMessage!
                                          .recentMessageTimestamp
                                          .microsecondsSinceEpoch
                                          .toString(),
                                    ),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: hasUnreadMessages
                                          ? CupertinoTheme.of(context)
                                              .primaryColor
                                          : CupertinoColors.inactiveGray,
                                    ),
                                  ),
                                  const SizedBox(height: 1),
                                  hasUnreadMessages
                                      ? Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: CupertinoTheme.of(context)
                                                .primaryColor,
                                            borderRadius:
                                                BorderRadius.circular(50),
                                          ),
                                          child: Text(
                                            snapshot.data.toString(),
                                            style: const TextStyle(
                                              color: CupertinoColors.white,
                                              fontSize: 12,
                                            ),
                                          ),
                                        )
                                      : const SizedBox(),
                                ],
                              );
                            },
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
            ),
          );
  }
}
