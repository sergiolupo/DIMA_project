import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/news/article_view.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/widgets/messages/message_utils.dart';
import 'package:flutter/cupertino.dart';

class NewsMessageTile extends StatelessWidget {
  final Message message;
  final String? senderUsername;
  const NewsMessageTile({
    required this.message,
    this.senderUsername,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => MessageUtils.showBottomSheet(
        context,
        message,
        showCustomSnackbar: null,
      ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: message.sentByMe! ? 24 : 0,
              right: message.sentByMe! ? 0 : 24,
            ),
            alignment: message.sentByMe!
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: message.sentByMe!
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!message.sentByMe! && message.isGroupMessage)
                  Padding(
                    padding: const EdgeInsets.only(right: 3.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 295),
                        CreateImageWidget.getUserImage(
                          message.senderImage!,
                          0,
                        ),
                      ],
                    ),
                  ),
                Container(
                  margin: message.sentByMe!
                      ? const EdgeInsets.only(left: 30)
                      : const EdgeInsets.only(right: 30),
                  padding: const EdgeInsets.only(
                      top: 8, left: 8, right: 8, bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: message.sentByMe!
                        ? const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
                          )
                        : const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                    color: message.sentByMe!
                        ? CupertinoTheme.of(context).primaryColor
                        : CupertinoColors.systemGrey,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (!message.sentByMe! && message.isGroupMessage)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              senderUsername!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: message.sentByMe!
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ],
                        ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              final List<String> news =
                                  message.content.split('\n');
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => ArticleView(
                                    blogUrl: news[2],
                                    description: news[1],
                                    imageUrl: news[3],
                                    title: news[0],
                                  ),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    message.content.split('\n').first,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: message.sentByMe!
                                          ? CupertinoColors.white
                                          : CupertinoColors.black,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 150,
                                  child: Text(
                                    message.content.split('\n')[1],
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: message.sentByMe!
                                          ? CupertinoColors.white
                                          : CupertinoColors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                CreateImageWidget.getImage(
                                  message.content.split('\n')[3],
                                  message.sentByMe!,
                                  small: false,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: message.sentByMe! ? 8 : 25,
            right: message.sentByMe! ? 8 : null,
            left: message.sentByMe!
                ? null
                : MediaQuery.of(context).size.width > Constants.limitWidth
                    ? 195
                    : MediaQuery.of(context).size.width / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateUtils.getFormattedTime(
                      context: context,
                      time: message.time.microsecondsSinceEpoch.toString()),
                  style: TextStyle(
                    color: message.sentByMe!
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(width: 8),
                MessageUtils.buildReadByIcon(
                  message,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
