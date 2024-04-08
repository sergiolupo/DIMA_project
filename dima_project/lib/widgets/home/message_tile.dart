import 'package:flutter/cupertino.dart';

class MessageTile extends StatefulWidget {
  final String message;
  final String sender;
  final bool sentByMe;
  const MessageTile({
    super.key,
    required this.message,
    required this.sender,
    required this.sentByMe,
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
        left: widget.sentByMe ? 0 : 24,
        right: widget.sentByMe ? 24 : 0,
      ),
      alignment: widget.sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: widget.sentByMe
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
          borderRadius: widget.sentByMe
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
          color: widget.sentByMe
              ? CupertinoTheme.of(context).primaryColor
              : CupertinoColors.systemGrey,
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                widget.sender,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: widget.sentByMe
                      ? CupertinoColors.white
                      : CupertinoColors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(widget.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: widget.sentByMe
                        ? CupertinoColors.white
                        : CupertinoColors.black,
                    fontSize: 16,
                  )),
            ]),
      ),
    );
  }
}
