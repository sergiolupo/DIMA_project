import 'package:dima_project/models/message.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/home/option_item.dart';
import 'package:dima_project/widgets/home/read_tile.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class MessageTile extends StatefulWidget {
  final Message message;
  final String username;

  const MessageTile({
    required this.message,
    required this.username,
    super.key,
  });

  @override
  MessageTileState createState() => MessageTileState();
}

class MessageTileState extends State<MessageTile> {
  bool _showSnackbar = false;
  late String _snackbarMessage;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showBottomSheet(context),
      child: Stack(
        children: [
          Container(
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
                  : const EdgeInsets.only(right: 30),
              padding: const EdgeInsets.symmetric(vertical: 17, horizontal: 20),
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
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CreateImageWidget.getUserImage(
                        widget.message.senderImage,
                        small: true,
                      ),
                      const SizedBox(width: 8),
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
                    ],
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.message.content,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: widget.message.sentByMe!
                              ? CupertinoColors.white
                              : CupertinoColors.black,
                          fontSize: 16,
                        ),
                      ),
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 8),
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
                              readBy(),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (_showSnackbar) _buildSnackbar(),
        ],
      ),
    );
  }

  Widget readBy() {
    bool hasRead = widget.message.readBy!
        .any((element) => element.username == widget.username);
    if (!hasRead) {
      DatabaseService.updateMessageReadStatus(widget.username, widget.message);
    }

    return widget.message.sentByMe == true
        ? widget.message.readBy!.isNotEmpty &&
                !widget.message.readBy!
                    .every((element) => element.username == widget.username)
            ? const Icon(CupertinoIcons.check_mark_circled,
                color: CupertinoColors.systemBlue, size: 18)
            : const Icon(CupertinoIcons.check_mark_circled,
                color: CupertinoColors.systemGreen, size: 18)
        : const SizedBox();
  }

  void _showBottomSheet(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return CupertinoActionSheet(
          actions: [
            OptionItem(
                icon: const Icon(
                  CupertinoIcons.doc_on_clipboard,
                  color: CupertinoColors.systemBlue,
                  size: 26,
                ),
                text: 'Copy Text',
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(text: widget.message.content),
                  );
                  if (!context.mounted) return;
                  Navigator.pop(context);
                  _showCustomSnackbar('Copied to clipboard');
                }),
            if (widget.message.sentByMe!)
              OptionItem(
                  icon: const Icon(
                    CupertinoIcons.pencil,
                    color: CupertinoColors.systemBlue,
                    size: 26,
                  ),
                  text: 'Edit Message',
                  onPressed: () {}),
            if (widget.message.sentByMe!)
              OptionItem(
                  icon: const Icon(
                    CupertinoIcons.delete,
                    color: CupertinoColors.systemRed,
                    size: 26,
                  ),
                  text: 'Delete Message',
                  onPressed: () {
                    if (!context.mounted) return;
                    Navigator.pop(context);
                    deleteMessage();
                  }),
            if (widget.message.sentByMe!)
              OptionItem(
                icon: const Icon(
                  CupertinoIcons.eye,
                  color: CupertinoColors.systemBlue,
                  size: 26,
                ),
                text: 'Read By',
                onPressed: showReaders,
              )
          ],
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  void _showCustomSnackbar(String message) {
    if (mounted) {
      setState(() {
        _snackbarMessage = message;
        _showSnackbar = true;
      });

      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _showSnackbar = false;
        });
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

  void showReaders() {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) {
        return Stack(
          children: <Widget>[
            Positioned.fill(
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  color: CupertinoColors.black.withOpacity(0.5),
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                ),
                decoration: const BoxDecoration(
                  color: CupertinoColors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Read By',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: widget.message.readBy!.length,
                        itemBuilder: (BuildContext context, int index) {
                          final reader = widget.message.readBy![index];
                          if (widget.message.sentByMe! &&
                              reader.username == widget.username) {
                            return const SizedBox.shrink();
                          }
                          return ReadTile(user: reader);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void deleteMessage() {
    showCupertinoDialog(
        context: context,
        builder: (_) {
          return CupertinoAlertDialog(
            title: const Text('Delete Message'),
            content:
                const Text('Are you sure you want to delete this message?'),
            actions: [
              CupertinoDialogAction(
                child: const Text('Yes'),
                onPressed: () {
                  DatabaseService.deleteMessage(widget.message);
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: const Text('No'),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        });
  }
}
