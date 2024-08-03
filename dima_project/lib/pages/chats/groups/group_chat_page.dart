import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/events/create_event_page.dart';
import 'package:dima_project/pages/chats/groups/group_info_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/chats/banner_message.dart';
import 'package:dima_project/widgets/chats/input_bar.dart';
import 'package:dima_project/widgets/chats/options_menu.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:dima_project/widgets/messages/event_message_tile.dart';
import 'package:dima_project/widgets/messages/image_message_tile.dart';
import 'package:dima_project/widgets/messages/news_message_tile.dart';
import 'package:dima_project/widgets/messages/text_message_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class GroupChatPage extends StatefulWidget {
  final Group group;
  final bool canNavigate;
  final Function? navigateToPage;
  const GroupChatPage({
    super.key,
    required this.canNavigate,
    required this.group,
    this.navigateToPage,
  });

  @override
  GroupChatPageState createState() => GroupChatPageState();
}

class GroupChatPageState extends State<GroupChatPage> {
  late final Stream<List<Message>> chats;
  TextEditingController messageEditingController = TextEditingController();
  bool isUploading = false;
  OverlayEntry? _optionsMenuOverlay;
  OverlayEntry? _clipboardOverlay;
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
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        key: _navigationBarKey,
        middle: CupertinoButton(
          padding: const EdgeInsets.all(0),
          onPressed: () async {
            if (!widget.canNavigate) {
              final Group? newGroup = await Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => GroupInfoPage(
                    group: group,
                    canNavigate: widget.canNavigate,
                    navigateToPage: widget.navigateToPage,
                  ),
                ),
              );
              if (newGroup != null) {
                setState(() {
                  group = newGroup;
                });
              }
            } else {
              widget.navigateToPage!(
                GroupInfoPage(
                  group: group,
                  canNavigate: widget.canNavigate,
                  navigateToPage: widget.navigateToPage,
                ),
              );
              return;
            }
          },
          child: Row(
            children: [
              CreateImageWidget.getGroupImage(group.imagePath!, small: true),
              const SizedBox(width: 10),
              Container(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.6),
                child: Text(group.name,
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          CupertinoTheme.of(context).textTheme.textStyle.color,
                    ),
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
        backgroundColor: CupertinoTheme.of(context).scaffoldBackgroundColor,
        leading: widget.canNavigate
            ? null
            : CupertinoButton(
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
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: CupertinoActivityIndicator(),
                  ),
                )
              : Container(),
          InputBar(
            key: _inputBarKey,
            focusNode: _focusNode,
            messageEditingController: messageEditingController,
            onTapCamera: onTapCamera,
            sendMessage: sendMessage,
            showOverlay: () => showOverlay(context),
            padding:
                const EdgeInsets.only(left: 15, right: 25, bottom: 25, top: 5),
            height: 50,
            buttonColor: CupertinoTheme.of(context).primaryColor,
            isGroupChat: true,
          )
        ],
      ),
    );
  }

  void showCustomSnackbar(bool isCopy) {
    if (mounted) {
      final RenderBox renderBox =
          _inputBarKey.currentContext!.findRenderObject() as RenderBox;
      final Size size = renderBox.size;
      _clipboardOverlay = OverlayEntry(
        builder: (context) => BannerMessage(
          size: size,
          canNavigate: widget.canNavigate,
          isCopy: isCopy,
        ),
      );
      Overlay.of(context).insert(_clipboardOverlay!);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _clipboardOverlay?.remove();
        }
      });
    }
  }

  void onTapCreateEvent() async {
    if (_optionsMenuOverlay?.mounted ?? false) {
      _optionsMenuOverlay?.remove();
    }
    if (widget.canNavigate) {
      widget.navigateToPage!(
        CreateEventPage(
          group: group,
          canNavigate: widget.canNavigate,
          navigateToPage: widget.navigateToPage,
        ),
      );
      return;
    }
    await Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (context) => CreateEventPage(
          group: group,
          canNavigate: false,
        ),
      ),
    );
  }

  void onTapCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image =
        await picker.pickImage(source: ImageSource.camera, imageQuality: 80);
    if (image != null) {
      if (mounted) {
        setState(() {
          isUploading = true;
        });
      }
      final bytes = await image.readAsBytes();
      await DatabaseService.sendChatImage(
        group.id,
        File(image.path),
        true,
        Uint8List.fromList(bytes),
      );
      if (mounted) {
        setState(() {
          isUploading = false;
        });
      }
    }
  }

  void onTapPhoto() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 80);

    if (images.isNotEmpty) {
      for (var image in images) {
        if (mounted) {
          setState(() {
            isUploading = true;
          });
        }
        final bytes = await image.readAsBytes();
        await DatabaseService.sendChatImage(
          group.id,
          File(image.path),
          true,
          Uint8List.fromList(bytes),
        );
        if (mounted) {
          setState(() {
            isUploading = false;
          });
        }
      }
    }
    if (_optionsMenuOverlay?.mounted ?? false) {
      _optionsMenuOverlay?.remove();
    }
  }

  Widget chatMessages() {
    return StreamBuilder<List<Message>>(
      stream: chats,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            physics: const ClampingScrollPhysics(),
            shrinkWrap: true,
            reverse: true,
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
                          DatabaseService.getUserDataFromUID(message.sender),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          message.senderImage = '';
                          return _buildMessageTile(message, 'Deleted Account');
                        }

                        if (snapshot.hasData) {
                          final user = UserData.fromSnapshot(snapshot.data!);
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
    _optionsMenuOverlay = OverlayEntry(
      builder: (context) => OptionsMenu(
        onTapCreateEvent: onTapCreateEvent,
        onTapCamera: onTapCamera,
        onTapPhoto: onTapPhoto,
        overlayEntry: _optionsMenuOverlay,
        isTablet: widget.canNavigate,
      ),
    );

    Overlay.of(context).insert(_optionsMenuOverlay!);
  }

  @override
  void dispose() {
    if (_clipboardOverlay?.mounted ?? false) {
      _clipboardOverlay?.remove();
    }
    super.dispose();
  }

  Widget _buildMessageTile(Message message, String senderUsername) {
    switch (message.type) {
      case Type.text:
        return TextMessageTile(
          showCustomSnackbar: () {
            showCustomSnackbar(true);
          },
          message: message,
          senderUsername: senderUsername,
        );
      case Type.image:
        return ImageMessageTile(
          message: message,
          senderUsername: senderUsername,
          showCustomSnackbar: () {
            showCustomSnackbar(false);
          },
        );
      case Type.news:
        return NewsMessageTile(
          message: message,
          senderUsername: senderUsername,
        );
      case Type.event:
      default:
        return EventMessageTile(
          message: message,
          senderUsername: senderUsername,
        );
    }
  }
}
