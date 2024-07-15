import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/private_info_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/widgets/messages/image_message_tile.dart';
import 'package:dima_project/widgets/messages/news_message_tile.dart';
import 'package:dima_project/widgets/messages/text_message_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PrivateChatPage extends StatefulWidget {
  final PrivateChat privateChat;
  final String uuid;

  const PrivateChatPage({
    super.key,
    required this.privateChat,
    required this.uuid,
  });

  @override
  PrivateChatPageState createState() => PrivateChatPageState();
}

class PrivateChatPageState extends State<PrivateChatPage> {
  Stream<List<Message>>? chats;
  TextEditingController messageEditingController = TextEditingController();
  bool isTyping = false;
  bool isUploading = false;
  final GlobalKey _inputBarKey = GlobalKey();
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    _checkPrivateChatId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: GestureDetector(
          onTap: () => {
            Navigator.of(context).push(
              CupertinoPageRoute(
                builder: (context) => PrivateInfoPage(
                  uuid: widget.uuid,
                  privateChat: widget.privateChat,
                ),
              ),
            )
          },
          child: SingleChildScrollView(
            child: StreamBuilder(
              stream: widget.privateChat.members[0] != widget.uuid
                  ? DatabaseService.getUserInfo(widget.privateChat.members[0])
                  : DatabaseService.getUserInfo(widget.privateChat.members[1]),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  final user =
                      UserData.fromSnapshot(snapshot.data as DocumentSnapshot);

                  return Row(
                    children: [
                      CreateImageWidget.getUserImage(
                        user.imagePath!,
                        small: true,
                      ),
                      const SizedBox(width: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              constraints: BoxConstraints(
                                maxWidth:
                                    MediaQuery.of(context).size.width * 0.6,
                              ),
                              child: Text(
                                user.username,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                            _userStatus(user),
                          ]),
                    ],
                  );
                } else {
                  return Container();
                }
              },
            ),
          ),
        ),
        backgroundColor: CupertinoTheme.of(context).primaryColor,
        leading: CupertinoButton(
          onPressed: () {
            if (isTyping && widget.privateChat.id != null) {
              DatabaseService.updateTyping(widget.privateChat.id!, false);
            }
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: const Icon(CupertinoIcons.back, color: CupertinoColors.white),
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: CupertinoActivityIndicator(),
                  ),
                )
              : Container(),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _userStatus(UserData user) {
    if (user.isTyping != null &&
        user.isTyping! &&
        user.typingTo == widget.privateChat.id) {
      return const Text(
        "is typing...",
        style: TextStyle(fontSize: 12),
      );
    } else {
      if (user.online != null && user.online!) {
        return const Text(
          "Online",
          style: TextStyle(fontSize: 12),
        );
      } else {
        if (user.lastSeen != null && !user.online!) {
          return Text(
            DateUtil.getLastSeenTime(
                context: context,
                time: user.lastSeen!.microsecondsSinceEpoch.toString()),
            style: const TextStyle(fontSize: 12),
          );
        }
      }
      return const SizedBox(height: 0, width: 0);
    }
  }

  Widget _buildInputBar() {
    return Container(
      key: _inputBarKey,
      color: CupertinoColors.inactiveGray,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          Expanded(
            child: CupertinoTextField(
              minLines: 1,
              maxLines: 3,
              controller: messageEditingController,
              style: const TextStyle(color: CupertinoColors.white),
              placeholder: "Type a message...",
              placeholderStyle: const TextStyle(color: CupertinoColors.white),
              decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.white),
                borderRadius: BorderRadius.circular(20),
              ),
              onChanged: (value) {
                if (value.isNotEmpty &&
                    !isTyping &&
                    widget.privateChat.id != null) {
                  isTyping = true;
                  DatabaseService.updateTyping(widget.privateChat.id!, true);
                } else if (value.isEmpty && isTyping) {
                  isTyping = false;
                  if (widget.privateChat.id != null) {
                    DatabaseService.updateTyping(widget.privateChat.id!, false);
                  }
                }
              },
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
                            widget.privateChat.id ??=
                                await DatabaseService.createPrivateChat(
                                    widget.privateChat);

                            await DatabaseService.sendChatImage(
                              widget.uuid,
                              widget.privateChat.id!,
                              File(image.path),
                              false,
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

                          widget.privateChat.id ??=
                              await DatabaseService.createPrivateChat(
                                  widget.privateChat);

                          await DatabaseService.sendChatImage(
                            widget.uuid,
                            widget.privateChat.id!,
                            File(image.path),
                            false,
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
                    (message.type == Type.text)
                        ? TextMessageTile(
                            message: message,
                            uuid: widget.uuid,
                            showCustomSnackbar: () {
                              showCustomSnackbar();
                            },
                          )
                        : (message.type == Type.image)
                            ? ImageMessageTile(
                                message: message,
                                uuid: widget.uuid,
                              )
                            : NewsMessageTile(
                                message: message,
                                uuid: widget.uuid,
                              ),
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

  void showCustomSnackbar() {
    if (mounted) {
      final RenderBox renderBox =
          _inputBarKey.currentContext!.findRenderObject() as RenderBox;
      final Size size = renderBox.size;
      debugPrint(size.toString());
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          bottom: size.height,
          left: 0,
          right: 0,
          child: const Center(
            child: Text(
              "Copied to clipboard",
              style: TextStyle(color: CupertinoColors.systemPink),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(_overlayEntry!);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _overlayEntry?.remove();
        }
      });
    }
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
        isGroupMessage: false,
        time: Timestamp.now(),
        readBy: [
          readBy,
        ],
        type: Type.text,
      );

      widget.privateChat.id ??=
          await DatabaseService.createPrivateChat(widget.privateChat);
      isTyping = false;
      DatabaseService.updateTyping(widget.privateChat.id!, false);
      DatabaseService.sendMessage(widget.privateChat.id!, message);

      setState(() {
        messageEditingController.clear();
      });
    }
  }

  _checkPrivateChatId() async {
    final idStream =
        DatabaseService.getPrivateChatIdFromMembers(widget.privateChat.members);

    await for (final id in idStream) {
      if (mounted) {
        setState(() {
          widget.privateChat.id = id;
          chats = DatabaseService.getPrivateChats(widget.privateChat.id);
        });
      }
    }
  }
}
