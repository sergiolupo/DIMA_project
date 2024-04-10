import 'package:dima_project/models/message.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class MessageTile extends StatefulWidget {
  final Message message;
  const MessageTile({
    super.key,
    required this.message,
  });

  @override
  MessageTileState createState() => MessageTileState();
}

class MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 8,
        bottom: 8,
        left: widget.message.sentByMe! ? 0 : 24,
        right: widget.message.sentByMe! ? 24 : 0,
      ),
      alignment: widget.message.sentByMe!
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        margin: widget.message.sentByMe!
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(
                right: 30,
              ),
        padding: const EdgeInsets.only(
          top: 17,
          bottom: 17,
          left: 20,
          right: 20,
        ),
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
              CreateImageWidget.getUserImage(widget.message.imagePath,
                  small: true),
              const SizedBox(height: 8),
              Text(
                widget.message.sender,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.message.sentByMe!
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(widget.message.content,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.message.sentByMe!
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                    fontSize: 16,
                  )),
            ]),
      ),
    );
  }
}
