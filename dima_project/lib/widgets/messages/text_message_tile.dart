import 'package:dima_project/models/message.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/widgets/messages/message_utils.dart';
import 'package:flutter/cupertino.dart';

class TextMessageTile extends StatefulWidget {
  final Message message;
  final String? senderUsername;
  final String uuid;
  const TextMessageTile({
    required this.message,
    this.senderUsername,
    required this.uuid,
    super.key,
  });

  @override
  TextMessageTileState createState() => TextMessageTileState();
}

class TextMessageTileState extends State<TextMessageTile> {
  bool _showSnackbar = false;
  late String _snackbarMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => MessageUtils.showBottomSheet(
          context, widget.message, widget.uuid,
          showCustomSnackbar: () => showCustomSnackbar('Copied to clipboard')),
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
                        const SizedBox(height: 45),
                        CreateImageWidget.getUserImage(
                          widget.message.senderImage!,
                          small: true,
                        ),
                      ],
                    ),
                  ),
                Flexible(
                  child: Stack(
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                          minWidth: 80,
                        ),
                        padding: const EdgeInsets.only(
                            top: 8.0, right: 8.0, left: 8.0, bottom: 24.0),
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
                            Text(
                              widget.message.content,
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                color: widget.message.sentByMe!
                                    ? CupertinoColors.white
                                    : CupertinoColors.black,
                                fontSize: 16,
                              ),
                              softWrap: true,
                              overflow: TextOverflow.visible,
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 3,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              DateUtil.getFormattedTime(
                                  context: context,
                                  time: widget
                                      .message.time.microsecondsSinceEpoch
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
                              widget.uuid,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (_showSnackbar) _buildSnackbar(),
        ],
      ),
    );
  }

  void showCustomSnackbar(String message) {
    if (mounted) {
      setState(() {
        _snackbarMessage = message;
        _showSnackbar = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _showSnackbar = false;
          });
        }
      });
    }
  }

  Widget _buildSnackbar() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: _showSnackbar ? MediaQuery.of(context).size.height * 0.1 : 0,
      color: CupertinoColors.white.withOpacity(0.7),
      child: Center(
        child: Text(
          _snackbarMessage,
          style: const TextStyle(color: CupertinoColors.systemPink),
        ),
      ),
    );
  }
}
