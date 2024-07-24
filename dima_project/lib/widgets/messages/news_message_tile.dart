import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/news/article_view.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/widgets/messages/message_utils.dart';
import 'package:flutter/cupertino.dart';

class NewsMessageTile extends StatefulWidget {
  final Message message;
  final String? senderUsername;
  const NewsMessageTile({
    required this.message,
    this.senderUsername,
    super.key,
  });

  @override
  NewsMessageTileState createState() => NewsMessageTileState();
}

class NewsMessageTileState extends State<NewsMessageTile> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => MessageUtils.showBottomSheet(
        context,
        widget.message,
        showCustomSnackbar: null,
      ),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: 8,
              bottom: 8,
              left: widget.message.sentByMe! ? 24 : 0,
              right: widget.message.sentByMe! ? 0 : 24,
            ),
            alignment: widget.message.sentByMe!
                ? Alignment.centerRight
                : Alignment.centerLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: widget.message.sentByMe!
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              children: [
                if (!widget.message.sentByMe! && widget.message.isGroupMessage)
                  Padding(
                    padding: const EdgeInsets.only(right: 3.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 295),
                        CreateImageWidget.getUserImage(
                          widget.message.senderImage!,
                          small: true,
                        ),
                      ],
                    ),
                  ),
                Container(
                  margin: widget.message.sentByMe!
                      ? const EdgeInsets.only(left: 30)
                      : const EdgeInsets.only(right: 30),
                  padding: const EdgeInsets.only(
                      top: 8, left: 8, right: 8, bottom: 10),
                  decoration: BoxDecoration(
                    borderRadius: widget.message.sentByMe!
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
                    color: widget.message.sentByMe!
                        ? CupertinoTheme.of(context).primaryColor
                        : CupertinoColors.systemGrey,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (!widget.message.sentByMe! &&
                          widget.message.isGroupMessage)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.senderUsername!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: widget.message.sentByMe!
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
                                  widget.message.content.split('\n');
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
                                    widget.message.content.split('\n').first,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: widget.message.sentByMe!
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
                                    widget.message.content.split('\n')[1],
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      color: widget.message.sentByMe!
                                          ? CupertinoColors.white
                                          : CupertinoColors.black,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                CreateImageWidget.getImage(
                                  widget.message.content.split('\n')[3],
                                  widget.message.sentByMe!,
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
            bottom: widget.message.sentByMe! ? 8 : 25,
            right: widget.message.sentByMe! ? 8 : null,
            left: widget.message.sentByMe!
                ? null
                : MediaQuery.of(context).size.width > Constants.limitWidth
                    ? 195
                    : MediaQuery.of(context).size.width / 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  DateUtil.getFormattedTime(
                      context: context,
                      time: widget.message.time.microsecondsSinceEpoch
                          .toString()),
                  style: TextStyle(
                    color: widget.message.sentByMe!
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                    fontSize: 9,
                  ),
                ),
                const SizedBox(width: 8),
                MessageUtils.buildReadByIcon(
                  widget.message,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
