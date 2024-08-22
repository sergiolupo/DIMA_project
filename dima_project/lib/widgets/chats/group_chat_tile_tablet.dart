import 'package:dima_project/models/group.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/models/message.dart';
import 'package:intl/intl.dart';

class GroupChatTileTablet extends StatelessWidget {
  final Group group;
  final Function(Group) onPressed;
  final String username;
  final Function(DismissDirection) onDismissed;
  GroupChatTileTablet({
    super.key,
    required this.group,
    required this.onPressed,
    required this.username,
    required this.onDismissed,
  });

  final Map<Type, Icon> map = {
    Type.event: const Icon(CupertinoIcons.calendar,
        color: CupertinoColors.inactiveGray, size: 16),
    Type.news: const Icon(CupertinoIcons.news,
        color: CupertinoColors.inactiveGray, size: 16),
    Type.image: const Icon(CupertinoIcons.photo,
        color: CupertinoColors.inactiveGray, size: 16),
  };

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
      onDismissed: onDismissed,
      child: CupertinoButton(
        padding: const EdgeInsets.all(0),
        onPressed: () {
          onPressed(group);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CreateImageWidget.getGroupImage(group.imagePath!,
                      small: true),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.2),
                        child: Text(
                          maxLines: 2,
                          group.name,
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
                      (group.lastMessage != null)
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  group.lastMessage!.sentByMe == true
                                      ? "You: "
                                      : "$username: ",
                                  style: const TextStyle(
                                      fontSize: 14,
                                      color: CupertinoColors.inactiveGray),
                                ),
                                if (group.lastMessage!.recentMessageType !=
                                    Type.text)
                                  map[group.lastMessage!.recentMessageType]!,
                                Container(
                                  constraints: BoxConstraints(
                                      maxWidth:
                                          MediaQuery.of(context).size.width *
                                              0.15),
                                  child: Text(
                                    maxLines: 2,
                                    group.lastMessage!.recentMessage,
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
                ],
              ),
              (group.lastMessage != null)
                  ? Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.05),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isBefore(DateTime.now()) &&
                                    DateTime.fromMicrosecondsSinceEpoch(group
                                            .lastMessage!
                                            .recentMessageTimestamp
                                            .microsecondsSinceEpoch)
                                        .isAfter(DateTime.now()
                                            .subtract(const Duration(days: 1)))
                                ? DateFormat.jm().format(
                                    DateTime.fromMicrosecondsSinceEpoch(group
                                        .lastMessage!
                                        .recentMessageTimestamp
                                        .microsecondsSinceEpoch))
                                : DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch)
                                        .isAfter(DateTime.now().subtract(const Duration(days: 2)))
                                    ? 'Yesterday'
                                    : DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isBefore(DateTime.now().subtract(const Duration(days: 1))) && DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch).isAfter(DateTime.now().subtract(const Duration(days: 7)))
                                        ? DateFormat.EEEE().format(DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch))
                                        : DateFormat.yMd().format(DateTime.fromMicrosecondsSinceEpoch(group.lastMessage!.recentMessageTimestamp.microsecondsSinceEpoch)),
                            style: TextStyle(
                              fontSize: 12,
                              color: group.lastMessage!.unreadMessages! > 0
                                  ? CupertinoTheme.of(context).primaryColor
                                  : CupertinoColors.inactiveGray,
                            ),
                          ),
                          const SizedBox(height: 1),
                          group.lastMessage!.unreadMessages! > 0
                              ? Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  child: Text(
                                    group.lastMessage!.unreadMessages
                                        .toString(),
                                    style: const TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 12),
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
                    )
                  : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
