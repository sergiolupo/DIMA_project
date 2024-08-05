import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/chats/media_view_page.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:dima_project/utils/message_utils.dart';
import 'package:flutter/cupertino.dart';

class ImageMessageTile extends StatelessWidget {
  final Message message;
  final String? senderUsername;
  final VoidCallback showCustomSnackbar;
  const ImageMessageTile({
    required this.message,
    this.senderUsername,
    super.key,
    required this.showCustomSnackbar,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => MessageUtils.showBottomSheet(
        context,
        message,
        showCustomSnackbar: showCustomSnackbar,
      ),
      onTap: () {
        Navigator.of(context).push(
          CupertinoPageRoute(
            builder: (context) => MediaViewPage(
              canNavigate: false,
              isGroup: message.isGroupMessage,
              media: message,
              messages: [message],
            ),
          ),
        );
      },
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
                        const SizedBox(height: 240),
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
                  padding: const EdgeInsets.only(top: 2, right: 2, left: 2),
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      if (!message.sentByMe! && message.isGroupMessage)
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(width: 8),
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
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CreateImageWidget.getImage(
                            message.content,
                            message.sentByMe!,
                            small: false,
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 10,
            right: message.sentByMe! ? 2 : null,
            left: message.sentByMe!
                ? null
                : MediaQuery.of(context).size.width > Constants.limitWidth
                    ? 150
                    : MediaQuery.of(context).size.width / 2 - 45,
            child: Row(
              children: [
                Text(
                  DateUtil.getFormattedTime(
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
