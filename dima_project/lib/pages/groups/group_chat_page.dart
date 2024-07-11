import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/groups/group_info_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/widgets/messages/image_message_tile.dart';
import 'package:dima_project/widgets/messages/news_message_tile.dart';
import 'package:dima_project/widgets/messages/text_message_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class GroupChatPage extends StatefulWidget {
  final Group group;
  final String uuid;

  const GroupChatPage({
    super.key,
    required this.group,
    required this.uuid,
  });

  @override
  GroupChatPageState createState() => GroupChatPageState();
}

class GroupChatPageState extends State<GroupChatPage> {
  Stream<List<Message>>? chats;
  TextEditingController messageEditingController = TextEditingController();
  bool isUploading = false;

  @override
  void initState() {
    getChats();
    super.initState();
  }

  void getChats() {
    chats = DatabaseService.getChats(widget.group.id);
  }

  @override
  Widget build(BuildContext context) {
    return chats == null
        ? const Center(child: CupertinoActivityIndicator())
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => GroupInfoPage(
                        uuid: widget.uuid,
                        group: widget.group,
                      ),
                    ),
                  );
                },
                child: Row(
                  children: [
                    CreateImageWidget.getGroupImage(widget.group.imagePath!,
                        small: true),
                    const SizedBox(width: 10),
                    Text(widget.group.name,
                        style: const TextStyle(
                            fontSize: 16, color: CupertinoColors.white)),
                  ],
                ),
              ),
              backgroundColor: CupertinoTheme.of(context).primaryColor,
              leading: CupertinoButton(
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go("/home", extra: 1);
                  }
                },
                child: const Icon(CupertinoIcons.back,
                    color: CupertinoColors.white),
              ),
            ),
            child: Column(
              children: <Widget>[
                Expanded(
                  child: chatMessages(),
                ),
                isUploading
                    ? const Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding:
                              EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: CupertinoActivityIndicator(),
                        ),
                      )
                    : Container(),
                _buildInputBar(),
              ],
            ),
          );
  }

  Widget _buildInputBar() {
    return Container(
      color: CupertinoColors.inactiveGray,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              controller: messageEditingController,
              style: const TextStyle(color: CupertinoColors.white),
              placeholder: "Type a message...",
              placeholderStyle: const TextStyle(color: CupertinoColors.white),
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.white),
                borderRadius: BorderRadius.circular(20),
              ),
              suffix: Container(
                padding: const EdgeInsets.only(right: 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        messageEditingController.clear();
                      },
                      child: const Icon(CupertinoIcons.clear_circled,
                          color: CupertinoColors.white),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 80);

                        if (images.isNotEmpty) {
                          for (var image in images) {
                            setState(() {
                              isUploading = true;
                            });
                            final bytes = await image.readAsBytes();
                            await DatabaseService.sendChatImage(
                              widget.uuid,
                              widget.group.id,
                              File(image.path),
                              true,
                              Uint8List.fromList(bytes),
                            );
                            setState(() {
                              isUploading = false;
                            });
                          }
                        }
                      },
                      child: const Icon(CupertinoIcons.photo_fill,
                          color: CupertinoColors.white),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        final ImagePicker picker = ImagePicker();
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 80);
                        if (image != null) {
                          setState(() {
                            isUploading = true;
                          });
                          final bytes = await image.readAsBytes();
                          await DatabaseService.sendChatImage(
                            widget.uuid,
                            widget.group.id,
                            File(image.path),
                            true,
                            Uint8List.fromList(bytes),
                          );
                          setState(() {
                            isUploading = false;
                          });
                        }
                      },
                      child: const Icon(CupertinoIcons.camera_fill,
                          color: CupertinoColors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () {
              sendMessage();
            },
            child: const Icon(CupertinoIcons.paperplane_fill,
                color: CupertinoColors.white),
          ),
        ],
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder<List<Message>>(
      stream: chats,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            reverse: true,
            physics: const BouncingScrollPhysics(),
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final message = snapshot.data![index];
              bool isSameDate = false;
              String? newDate = '';

              // Convert timestamp to DateTime
              final DateTime messageDate = DateTime.fromMillisecondsSinceEpoch(
                  message.time.seconds * 1000);

              // Format the date
              final String date = DateUtil.formatDateBasedOnToday(messageDate);
              if (index == snapshot.data!.length - 1) {
                newDate = date;
              } else {
                final String prevDate = DateUtil.formatDateBasedOnToday(
                    DateTime.fromMillisecondsSinceEpoch(
                        snapshot.data![index + 1].time.seconds * 1000));
                isSameDate = date == prevDate;
                newDate = isSameDate ? '' : date;
              }
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    newDate.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ClipOval(
                              child: Container(
                                color: CupertinoColors.systemGrey3,
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  newDate,
                                  style: const TextStyle(
                                    color: CupertinoColors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    StreamBuilder(
                      stream:
                          DatabaseService.getUserDataFromUUID(message.sender),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final user = snapshot.data as UserData;

                          message.senderImage = user.imagePath;
                          if (message.type == Type.text) {
                            return TextMessageTile(
                                message: message,
                                uuid: widget.uuid,
                                senderUsername: user.username);
                          }
                          if (message.type == Type.image) {
                            return ImageMessageTile(
                              message: message,
                              uuid: widget.uuid,
                              senderUsername: user.username,
                            );
                          }
                          return NewsMessageTile(
                            message: message,
                            uuid: widget.uuid,
                            senderUsername: user.username,
                          );
                        } else {
                          return Container();
                        }
                      },
                    )
                  ],
                ),
              );
            },
          );
        } else {
          return Container();
        }
      },
    );
  }

  void sendMessage() async {
    if (messageEditingController.text.isNotEmpty) {
      ReadBy readBy = ReadBy(
        readAt: Timestamp.now(),
        username: FirebaseAuth.instance.currentUser!.uid,
      );
      Message message = Message(
        content: messageEditingController.text,
        sender: FirebaseAuth.instance.currentUser!.uid,
        isGroupMessage: true,
        time: Timestamp.now(),
        readBy: [
          readBy,
        ],
        type: Type.text,
      );

      DatabaseService.sendMessage(widget.group.id, message);

      setState(() {
        messageEditingController.clear();
      });
    }
  }
}
