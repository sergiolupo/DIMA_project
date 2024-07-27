import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/private_chat_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/models/message.dart';

class PrivateChatTile extends StatefulWidget {
  final PrivateChat privateChat;
  final UserData other;
  const PrivateChatTile({
    super.key,
    required this.privateChat,
    required this.other,
  });

  @override
  PrivateChatTileState createState() => PrivateChatTileState();
}

class PrivateChatTileState extends State<PrivateChatTile> {
  Map<Type, Icon> map = {
    Type.event: const Icon(CupertinoIcons.calendar,
        color: CupertinoColors.inactiveGray, size: 16),
    Type.news: const Icon(CupertinoIcons.news,
        color: CupertinoColors.inactiveGray, size: 16),
    Type.image: const Icon(CupertinoIcons.photo,
        color: CupertinoColors.inactiveGray, size: 16),
  };
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(),
      direction: DismissDirection.endToStart,
      background: Container(
        color: CupertinoColors.systemRed,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        alignment: Alignment.centerRight,
        child: const Icon(
          CupertinoIcons.trash,
          color: CupertinoColors.white,
        ),
      ),
      onDismissed: (direction) async {
        await DatabaseService.deletePrivateChat(widget.privateChat);
      },
      child: CupertinoButton(
        padding: const EdgeInsets.all(0),
        onPressed: () {
          setState(() {
            widget.privateChat.lastMessage!.unreadMessages = 0;
          });
          Navigator.of(context, rootNavigator: true).push(
            CupertinoPageRoute(
              builder: (context) => PrivateChatPage(
                privateChat: widget.privateChat,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CreateImageWidget.getUserImage(widget.other.imagePath!,
                      small: true),
                  const SizedBox(width: 16),
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.other.username,
                          style: TextStyle(
                              color: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        (widget.privateChat.lastMessage != null)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.privateChat.lastMessage!.sentByMe ==
                                            true
                                        ? "You: "
                                        : "${widget.other.username}: ",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: CupertinoColors.inactiveGray),
                                  ),
                                  if (widget.privateChat.lastMessage!
                                          .recentMessageType !=
                                      Type.text)
                                    map[widget.privateChat.lastMessage!
                                        .recentMessageType]!,
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.4),
                                    child: Text(
                                      maxLines: 2,
                                      widget.privateChat.lastMessage!
                                          .recentMessage,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          color: CupertinoColors.inactiveGray),
                                    ),
                                  ),
                                ],
                              )
                            : const Text(
                                "Join the conversation!",
                                style: TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.inactiveGray),
                              ),
                      ],
                    ),
                  ),
                ],
              ),
              (widget.privateChat.lastMessage != null)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          DateUtil.getFormattedTime(
                            context: context,
                            time: widget.privateChat.lastMessage!
                                .recentMessageTimestamp.microsecondsSinceEpoch
                                .toString(),
                          ),
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.privateChat.lastMessage!
                                        .unreadMessages! >
                                    0
                                ? CupertinoTheme.of(context).primaryColor
                                : CupertinoColors.inactiveGray,
                          ),
                        ),
                        const SizedBox(height: 1),
                        widget.privateChat.lastMessage!.unreadMessages! > 0
                            ? Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  widget
                                      .privateChat.lastMessage!.unreadMessages!
                                      .toString(),
                                  style: const TextStyle(
                                      color: CupertinoColors.white,
                                      fontSize: 12),
                                ),
                              )
                            : const SizedBox(),
                      ],
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
