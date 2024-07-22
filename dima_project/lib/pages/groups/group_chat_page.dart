import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/events/create_event_page.dart';
import 'package:dima_project/pages/groups/group_info_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/widgets/messages/event_message_tile.dart';
import 'package:dima_project/widgets/messages/image_message_tile.dart';
import 'package:dima_project/widgets/messages/news_message_tile.dart';
import 'package:dima_project/widgets/messages/text_message_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

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
  OverlayEntry? _overlayEntry;
  OverlayEntry? _copyOverlayEntry;
  final GlobalKey _navigationBarKey = GlobalKey();
  final GlobalKey _inputBarKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();

  late Group group;

  @override
  void initState() {
    group = widget.group;
    getChats();
    super.initState();
  }

  void getChats() {
    chats = DatabaseService.getChats(group.id);
  }

  @override
  Widget build(BuildContext context) {
    return chats == null
        ? const Center(child: CupertinoActivityIndicator())
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              key: _navigationBarKey,
              middle: CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () async {
                  final Group? newGroup = await Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (context) => GroupInfoPage(
                        uuid: widget.uuid,
                        group: group,
                      ),
                    ),
                  );
                  if (newGroup != null) {
                    setState(() {
                      group = newGroup;
                    });
                  }
                },
                child: Row(
                  children: [
                    CreateImageWidget.getGroupImage(group.imagePath!,
                        small: true),
                    const SizedBox(width: 10),
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.6),
                      child: Text(group.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .color,
                          ),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              ),
              backgroundColor:
                  CupertinoTheme.of(context).scaffoldBackgroundColor,
              leading: CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go("/home", extra: 1);
                  }
                },
                child: Icon(CupertinoIcons.back,
                    color: CupertinoTheme.of(context).primaryColor),
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

  void showCustomSnackbar() {
    if (mounted) {
      final RenderBox renderBox =
          _inputBarKey.currentContext!.findRenderObject() as RenderBox;
      final Size size = renderBox.size;
      _copyOverlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          bottom: size.height,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: Container(
              padding: const EdgeInsets.only(
                  right: 80, left: 10, bottom: 10, top: 10),
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: CupertinoTheme.of(context).primaryContrastingColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(CupertinoIcons.rectangle_fill_on_rectangle_fill,
                      color: CupertinoTheme.of(context).primaryColor),
                  const SizedBox(width: 10),
                  Text(
                    "Copied to clipboard",
                    style: TextStyle(
                        color: CupertinoTheme.of(context).primaryColor),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      Overlay.of(context).insert(_copyOverlayEntry!);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _copyOverlayEntry?.remove();
        }
      });
    }
  }

  Widget _buildInputBar() {
    return Container(
      key: _inputBarKey,
      color: CupertinoColors.inactiveGray,
      padding: const EdgeInsets.only(left: 15, right: 25, bottom: 25, top: 5),
      child: Row(
        children: [
          Focus(
            child: CupertinoButton(
                padding: const EdgeInsets.all(2),
                onPressed: () {
                  _focusNode.unfocus();
                  showOverlay(context);
                },
                child: const Icon(CupertinoIcons.add,
                    color: CupertinoColors.white, size: 30)),
          ),
          Expanded(
            child: SizedBox(
              height: 50,
              child: CupertinoTextField(
                focusNode: _focusNode,
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
                        onTap: () {
                          onTapCamera();
                        },
                        child: const Icon(CupertinoIcons.camera_fill,
                            color: CupertinoColors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          CupertinoButton(
            borderRadius: BorderRadius.circular(20),
            padding: const EdgeInsets.all(2),
            color: CupertinoTheme.of(context).primaryColor,
            onPressed: () {
              sendMessage();
            },
            child: const Icon(LineAwesomeIcons.paper_plane,
                color: CupertinoColors.white),
          ),
        ],
      ),
    );
  }

  void onTapCreateEvent() async {
    _overlayEntry?.remove();

    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => CreateEventPage(
          uuid: widget.uuid,
          groupId: group.id,
        ),
      ),
    );
  }

  void onTapCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) {
      setState(() {
        isUploading = true;
      });
      final bytes = await image.readAsBytes();
      await DatabaseService.sendChatImage(
        widget.uuid,
        group.id,
        File(image.path),
        true,
        Uint8List.fromList(bytes),
      );
      setState(() {
        isUploading = false;
      });
    }
  }

  void onTapPhoto() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 80);

    if (images.isNotEmpty) {
      for (var image in images) {
        setState(() {
          isUploading = true;
        });
        final bytes = await image.readAsBytes();
        await DatabaseService.sendChatImage(
          widget.uuid,
          group.id,
          File(image.path),
          true,
          Uint8List.fromList(bytes),
        );
        setState(() {
          isUploading = false;
        });
      }
    }
    _overlayEntry?.remove();
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
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Column(
                  children: [
                    newDate.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: CupertinoTheme.of(context)
                                    .primaryContrastingColor,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Text(
                                newDate,
                                style: TextStyle(
                                  color: CupertinoTheme.of(context)
                                      .textTheme
                                      .textStyle
                                      .color,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          )
                        : Container(),
                    StreamBuilder(
                      stream:
                          DatabaseService.getUserDataFromUUID(message.sender),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          message.senderImage = '';
                          return _buildMessageTile(message, 'Account Deleted');
                        }

                        if (snapshot.hasData) {
                          final user = snapshot.data as UserData;
                          message.senderImage = user.imagePath;
                          return _buildMessageTile(message, user.username);
                        }
                        return Container();
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

      DatabaseService.sendMessage(group.id, message);

      setState(() {
        messageEditingController.clear();
      });
    }
  }

  void showOverlay(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (context) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _overlayEntry?.remove();
              },
              child: Container(
                  color: const Color(
                      0x00000000) // ARGB value: A=00, R=00, G=00, B=00
                  ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.only(top: 10),
              height: 100,
              color: CupertinoColors.inactiveGray,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    onTap: onTapCreateEvent,
                    child: Column(
                      children: [
                        Icon(CupertinoIcons.calendar,
                            color: CupertinoTheme.of(context).primaryColor),
                        Text("Create Event",
                            style: TextStyle(
                                color: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle
                                    .color)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      onTapCamera();
                      _overlayEntry?.remove();
                    },
                    child: Column(
                      children: [
                        Icon(CupertinoIcons.camera_fill,
                            color: CupertinoTheme.of(context).primaryColor),
                        Text("Camera",
                            style: TextStyle(
                                color: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle
                                    .color)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: onTapPhoto,
                    child: Column(
                      children: [
                        Icon(CupertinoIcons.photo_fill,
                            color: CupertinoTheme.of(context).primaryColor),
                        Text("Photo",
                            style: TextStyle(
                                color: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle
                                    .color)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
    }
    if (_copyOverlayEntry != null) {
      _copyOverlayEntry?.remove();
    }
    super.dispose();
  }

  Widget _buildMessageTile(Message message, String senderUsername) {
    switch (message.type) {
      case Type.text:
        return TextMessageTile(
          showCustomSnackbar: showCustomSnackbar,
          message: message,
          uuid: widget.uuid,
          senderUsername: senderUsername,
        );
      case Type.image:
        return ImageMessageTile(
          message: message,
          uuid: widget.uuid,
          senderUsername: senderUsername,
        );
      case Type.news:
        return NewsMessageTile(
          message: message,
          uuid: widget.uuid,
          senderUsername: senderUsername,
        );
      case Type.event:
      default:
        return EventMessageTile(
          message: message,
          uuid: widget.uuid,
          senderUsername: senderUsername,
        );
    }
  }
}
