import 'dart:io';

import 'package:dima_project/models/message.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/home/option_item.dart';
import 'package:dima_project/widgets/home/read_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

class MessageUtils {
  static void showBottomSheet(
      BuildContext context, Message message, String uuid,
      {required VoidCallback? showCustomSnackbar}) {
    List<Widget> actions = [
      if (message.type == Type.text)
        _buildOptionItem(
          icon: CupertinoIcons.doc_on_clipboard,
          color: CupertinoColors.systemBlue,
          text: 'Copy Text',
          onPressed: () => _copyText(context, message, showCustomSnackbar!),
          context: context,
        ),
      if (message.type == Type.image)
        _buildOptionItem(
          icon: CupertinoIcons.download_circle,
          color: CupertinoColors.systemBlue,
          text: 'Save Image',
          onPressed: () => _saveImage(message),
          context: context,
        ),
      if (message.sentByMe! && message.type == Type.text)
        _buildOptionItem(
          icon: CupertinoIcons.pencil,
          color: CupertinoColors.systemBlue,
          text: 'Edit Message',
          onPressed: () => _editMessage(context, message),
          context: context,
        ),
      if (message.sentByMe!)
        _buildOptionItem(
          icon: CupertinoIcons.delete,
          color: CupertinoColors.systemRed,
          text: 'Delete Message',
          onPressed: () => _deleteMessage(context, message),
          context: context,
        ),
      if (message.sentByMe!)
        _buildOptionItem(
          icon: CupertinoIcons.eye,
          color: CupertinoColors.systemBlue,
          text: 'Read By',
          onPressed: () => _showReaders(context, message, uuid),
          context: context,
        ),
    ];

    showCupertinoModalPopup(
      context: context,
      builder: (_) {
        return CupertinoActionSheet(
          actions: actions,
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        );
      },
    );
  }

  static Widget _buildOptionItem(
      {required IconData icon,
      required Color color,
      required String text,
      required VoidCallback onPressed,
      required BuildContext context}) {
    return OptionItem(
      icon: Icon(icon, color: color, size: 26),
      text: text,
      onPressed: () {
        Navigator.pop(context);
        onPressed();
      },
    );
  }

  static Widget buildReadByIcon(Message message, String uuid) {
    bool hasRead = message.readBy!.any((element) => element.username == uuid);
    if (!hasRead) {
      DatabaseService.updateMessageReadStatus(uuid, message);
    }

    return message.sentByMe == true
        ? message.readBy!.isNotEmpty &&
                !message.readBy!.every((element) => element.username == uuid)
            ? const Icon(CupertinoIcons.check_mark_circled,
                color: CupertinoColors.systemBlue, size: 10)
            : const Icon(CupertinoIcons.check_mark_circled,
                color: CupertinoColors.systemGreen, size: 10)
        : const SizedBox();
  }

  static Future<void> _copyText(BuildContext context, Message message,
      VoidCallback showCustomSnackbar) async {
    await Clipboard.setData(ClipboardData(text: message.content));
    if (context.mounted) showCustomSnackbar();
  }

  static Future<File> _saveImage(Message message) async {
    // Get the directory to save the file.
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/${const Uuid().v4()}.png';
    // Fetch the image from the URL.
    final response = await http.get(Uri.parse(message.content));

    // Check if the request was successful.
    if (response.statusCode == 200) {
      debugPrint('Image downloaded successfully');
      // Write the image data to the file.
      final file = File(filePath);
      return file.writeAsBytes(response.bodyBytes);
    } else {
      throw Exception('Failed to download image');
    }
  }

  static void _editMessage(BuildContext context, Message message) {
    String updatedMessage = message.content;
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: const Row(
            children: [
              Icon(CupertinoIcons.pencil,
                  color: CupertinoColors.activeBlue, size: 28),
              SizedBox(width: 10),
              Text("Edit Message"),
            ],
          ),
          content: CupertinoTextField(
            controller: TextEditingController(text: updatedMessage),
            onChanged: (value) {
              updatedMessage = value;
            },
            decoration: Constants.inputDecoration,
          ),
          actions: [
            CupertinoDialogAction(
              child: const Text('Update'),
              onPressed: () {
                DatabaseService.updateMessageContent(message, updatedMessage);
                Navigator.pop(context);
              },
            ),
            CupertinoDialogAction(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  static void _deleteMessage(BuildContext context, Message message) {
    showCupertinoDialog(
      context: context,
      builder: (_) {
        return CupertinoAlertDialog(
          title: const Text('Delete Message'),
          content: const Text('Are you sure you want to delete this message?'),
          actions: [
            CupertinoDialogAction(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.pop(context);
                DatabaseService.deleteMessage(message);
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
      },
    );
  }

  static void _showReaders(BuildContext context, Message message, String uuid) {
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
                        itemCount: message.readBy!.length,
                        itemBuilder: (BuildContext context, int index) {
                          final reader = message.readBy![index];
                          if (message.sentByMe! && reader.username == uuid) {
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
}
