import 'package:dima_project/models/group.dart';
import 'package:dima_project/pages/chats/groups/group_chat_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/models/message.dart';
import 'package:intl/intl.dart';

class GroupChatTile extends StatefulWidget {
  final Group group;
  final String? username;
  const GroupChatTile({
    super.key,
    required this.group,
    this.username,
  });

  @override
  GroupChatTileState createState() => GroupChatTileState();
}

class GroupChatTileState extends State<GroupChatTile> {
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
        await DatabaseService.toggleGroupJoin(
          widget.group.id,
        );
      },
      child: CupertinoButton(
        padding: const EdgeInsets.all(0),
        onPressed: () {
          setState(() {
            if (widget.group.lastMessage != null) {
              widget.group.lastMessage!.unreadMessages = 0;
            }
          });
          Navigator.of(context, rootNavigator: true).push(
            CupertinoPageRoute(
              builder: (context) => GroupChatPage(
                group: widget.group,
                canNavigate: false,
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
                  CreateImageWidget.getGroupImage(widget.group.imagePath!,
                      small: true),
                  const SizedBox(width: 16),
                  Container(
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.6),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.4),
                          child: Text(
                            maxLines: 2,
                            widget.group.name,
                            style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                color: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle
                                    .color,
                                fontWeight: FontWeight.bold,
                                fontSize: 16),
                          ),
                        ),
                        const SizedBox(height: 2),
                        (widget.group.lastMessage != null)
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.group.lastMessage!.sentByMe == true
                                        ? "You: "
                                        : "${widget.username!}: ",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: CupertinoColors.inactiveGray),
                                  ),
                                  if (widget.group.lastMessage!
                                          .recentMessageType !=
                                      Type.text)
                                    map[widget
                                        .group.lastMessage!.recentMessageType]!,
                                  Container(
                                    constraints: BoxConstraints(
                                        maxWidth:
                                            MediaQuery.of(context).size.width *
                                                0.4),
                                    child: Text(
                                      maxLines: 2,
                                      widget.group.lastMessage!.recentMessage,
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
              (widget.group.lastMessage != null)
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          DateTime.fromMicrosecondsSinceEpoch(widget.group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch)
                                      .isBefore(DateTime.now()) &&
                                  DateTime.fromMicrosecondsSinceEpoch(widget.group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch)
                                      .isAfter(DateTime.now()
                                          .subtract(const Duration(days: 1)))
                              ? DateFormat.jm().format(
                                  DateTime.fromMicrosecondsSinceEpoch(widget
                                      .group
                                      .lastMessage!
                                      .recentMessageTimestamp
                                      .microsecondsSinceEpoch))
                              : DateTime.fromMicrosecondsSinceEpoch(widget.group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isBefore(DateTime.now().subtract(const Duration(days: 1))) &&
                                      DateTime.fromMicrosecondsSinceEpoch(widget.group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch)
                                          .isAfter(DateTime.now().subtract(const Duration(days: 7)))
                                  ? DateFormat.EEEE().format(DateTime.fromMicrosecondsSinceEpoch(widget.group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch))
                                  : DateFormat.yMd().format(DateTime.fromMicrosecondsSinceEpoch(widget.group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch)),
                          style: TextStyle(
                            fontSize: 12,
                            color: widget.group.lastMessage!.unreadMessages! > 0
                                ? CupertinoTheme.of(context).primaryColor
                                : CupertinoColors.inactiveGray,
                          ),
                        ),
                        const SizedBox(height: 1),
                        widget.group.lastMessage!.unreadMessages! > 0
                            ? Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Text(
                                  widget.group.lastMessage!.unreadMessages!
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
