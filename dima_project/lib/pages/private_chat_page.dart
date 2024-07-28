import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/private_info_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/chats/clipboard_banner.dart';
import 'package:dima_project/widgets/chats/input_bar.dart';
import 'package:dima_project/widgets/chats/options_menu.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/widgets/messages/event_message_tile.dart';
import 'package:dima_project/widgets/messages/image_message_tile.dart';
import 'package:dima_project/widgets/messages/news_message_tile.dart';
import 'package:dima_project/widgets/messages/text_message_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class PrivateChatPage extends StatefulWidget {
  final PrivateChat privateChat;
  final bool canNavigate;
  final Function? navigateToPage;
  final UserData user;
  const PrivateChatPage({
    super.key,
    required this.privateChat,
    required this.canNavigate,
    this.navigateToPage,
    required this.user,
  });

  @override
  PrivateChatPageState createState() => PrivateChatPageState();
}

class PrivateChatPageState extends State<PrivateChatPage> {
  Stream<List<Message>>? chats;
  TextEditingController messageEditingController = TextEditingController();
  final String uid = AuthService.uid;
  bool isUploading = false;
  final GlobalKey _inputBarKey = GlobalKey();
  OverlayEntry? _clipboardOverlay;
  OverlayEntry? _optionsMenuOverlay;
  final FocusNode _focusNode = FocusNode();

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
          onTap: () {
            if (widget.privateChat.id != null) {
              if (!widget.canNavigate) {
                Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => PrivateInfoPage(
                    privateChat: widget.privateChat,
                    canNavigate: widget.canNavigate,
                    navigateToPage: widget.navigateToPage,
                    user: widget.user,
                  ),
                ));
              } else {
                widget.navigateToPage!(
                  PrivateInfoPage(
                    privateChat: widget.privateChat,
                    canNavigate: widget.canNavigate,
                    navigateToPage: widget.navigateToPage,
                    user: widget.user,
                  ),
                );
                return;
              }
            }
          },
          child: Row(
            children: [
              CreateImageWidget.getUserImage(
                widget.user.imagePath!,
                small: true,
              ),
              const SizedBox(width: 10),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.6,
                ),
                child: Text(
                  widget.user.username,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: (!widget.canNavigate)
            ? CupertinoButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  }
                },
                child: Icon(CupertinoIcons.back,
                    color: CupertinoTheme.of(context).primaryColor),
              )
            : null,
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
            buttonColor: CupertinoTheme.of(context).primaryColor,
          )
        ],
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

      widget.privateChat.id ??=
          await DatabaseService.createPrivateChat(widget.privateChat);

      await DatabaseService.sendChatImage(
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

  void onTapPhoto() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage(imageQuality: 80);

    if (images.isNotEmpty) {
      for (var image in images) {
        setState(() {
          isUploading = true;
        });
        final bytes = await image.readAsBytes();
        widget.privateChat.id ??=
            await DatabaseService.createPrivateChat(widget.privateChat);

        await DatabaseService.sendChatImage(
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
    _optionsMenuOverlay?.remove();
  }

  Widget chatMessages() {
    return StreamBuilder<List<Message>>(
      stream: chats,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            shrinkWrap: true,
            reverse: true,
            physics: const ClampingScrollPhysics(),
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
                    (message.type == Type.text)
                        ? Hero(
                            tag: message.id!,
                            child: TextMessageTile(
                              message: message,
                              showCustomSnackbar: () {
                                showCustomSnackbar();
                              },
                            ),
                          )
                        : (message.type == Type.image)
                            ? ImageMessageTile(
                                message: message,
                              )
                            : message.type == Type.news
                                ? NewsMessageTile(
                                    message: message,
                                  )
                                : EventMessageTile(
                                    message: message,
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
      _clipboardOverlay = OverlayEntry(
        builder: (context) => ClipboardBanner(size: size, canNavigate: false),
      );
      Overlay.of(context).insert(_clipboardOverlay!);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _clipboardOverlay?.remove();
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

  void showOverlay(BuildContext context) {
    _optionsMenuOverlay = OverlayEntry(
        builder: (context) => OptionsMenu(
            isTablet: false,
            onTapCamera: onTapCamera,
            onTapPhoto: onTapPhoto,
            overlayEntry: _optionsMenuOverlay));

    Overlay.of(context).insert(_optionsMenuOverlay!);
  }

  @override
  void dispose() {
    if (_optionsMenuOverlay?.mounted ?? false) {
      _optionsMenuOverlay?.remove();
    }
    if (_clipboardOverlay?.mounted ?? false) {
      _clipboardOverlay?.remove();
    }
    super.dispose();
  }
}
