import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/last_message.dart';
import 'package:dima_project/pages/groups/group_chat_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class GroupChatTile extends StatefulWidget {
  final String uuid;
  final Group group;
  final LastMessage? lastMessage;
  const GroupChatTile({
    super.key,
    required this.uuid,
    required this.group,
    required this.lastMessage,
  });

  @override
  GroupChatTileState createState() => GroupChatTileState();
}

class GroupChatTileState extends State<GroupChatTile> {
  Stream<int>? unreadMessagesStream;

  @override
  void initState() {
    super.initState();
    unreadMessagesStream =
        DatabaseService.getUnreadMessages(true, widget.group.id, widget.uuid);
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
        await DatabaseService.toggleGroupJoin(widget.group.id, widget.uuid);
      },
      child: GestureDetector(
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            CupertinoPageRoute(
              builder: (context) => GroupChatPage(
                uuid: widget.uuid,
                group: widget.group,
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
                        Text(
                          widget.group.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 2),
                        (widget.lastMessage != null)
                            ? Text(
                                widget.lastMessage!.sentByMe == true
                                    ? "You: ${widget.lastMessage!.recentMessage}"
                                    : "${widget.lastMessage!.recentMessageSender}: ${widget.lastMessage!.recentMessage}",
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: CupertinoColors.inactiveGray),
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
              (widget.lastMessage != null)
                  ? StreamBuilder(
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
                                time: widget.lastMessage!.recentMessageTimestamp
                                    .microsecondsSinceEpoch
                                    .toString(),
                              ),
                              style: TextStyle(
                                fontSize: 12,
                                color: hasUnreadMessages
                                    ? CupertinoTheme.of(context).primaryColor
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
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                    child: Text(
                                      snapshot.data.toString(),
                                      style: const TextStyle(
                                          color: CupertinoColors.white,
                                          fontSize: 12),
                                    ),
                                  )
                                : const SizedBox(),
                          ],
                        );
                      },
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
