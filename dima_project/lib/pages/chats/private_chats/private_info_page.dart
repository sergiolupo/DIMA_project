import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/chats/private_chats/private_chat_page.dart';
import 'package:dima_project/pages/chats/show_events_page.dart';
import 'package:dima_project/pages/chats/show_medias_page.dart';
import 'package:dima_project/pages/chats/show_news_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:flutter/cupertino.dart';

class PrivateInfoPage extends StatefulWidget {
  final PrivateChat privateChat;
  final Function? navigateToPage;
  final bool canNavigate;
  final UserData user;
  const PrivateInfoPage({
    super.key,
    required this.privateChat,
    this.navigateToPage,
    required this.canNavigate,
    required this.user,
  });

  @override
  PrivateInfoPageState createState() => PrivateInfoPageState();
}

class PrivateInfoPageState extends State<PrivateInfoPage> {
  final String uid = AuthService.uid;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          onPressed: () {
            if (widget.canNavigate) {
              widget.navigateToPage!(PrivateChatPage(
                privateChat: widget.privateChat,
                canNavigate: widget.canNavigate,
                navigateToPage: widget.navigateToPage,
                user: widget.user,
              ));
              return;
            }
            Navigator.of(context).pop();
          },
          child: Icon(CupertinoIcons.back,
              color: CupertinoTheme.of(context).primaryColor),
        ),
        middle: Text("Private Chat Info",
            style: TextStyle(color: CupertinoTheme.of(context).primaryColor)),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      ),
      child: CupertinoScrollbar(
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: const BoxDecoration(),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              CreateImageWidget.getUserImage(
                                  widget.user.imagePath!, 1),
                              const SizedBox(width: 20),
                              Text(
                                widget.user.username,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${widget.user.name} ${widget.user.surname}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: CupertinoColors.systemGrey,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder(
                        future: _databaseService.getPrivateMessagesType(
                            widget.privateChat.id!, Type.image),
                        builder: (context, snapshot) {
                          return CupertinoListTile(
                            padding: const EdgeInsets.all(0),
                            title: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.photo_on_rectangle,
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 10),
                                const Text("Media"),
                              ],
                            ),
                            trailing: Row(
                              children: [
                                snapshot.connectionState ==
                                            ConnectionState.waiting ||
                                        snapshot.hasError ||
                                        snapshot.data!.isEmpty
                                    ? const SizedBox()
                                    : Text(
                                        snapshot.data!.length.toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                          color:
                                              CupertinoColors.opaqueSeparator,
                                        ),
                                      ),
                                const SizedBox(width: 10),
                                Icon(
                                  CupertinoIcons.right_chevron,
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                  size: 18,
                                ),
                              ],
                            ),
                            onTap: () {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  snapshot.hasError) {
                                return;
                              }
                              List<Message> media = snapshot.data!;
                              if (widget.canNavigate) {
                                widget.navigateToPage!(ShowMediasPage(
                                  privateChat: widget.privateChat,
                                  medias: media,
                                  canNavigate: true,
                                  navigateToPage: widget.navigateToPage,
                                  isGroup: false,
                                  user: widget.user,
                                ));
                                return;
                              }
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => ShowMediasPage(
                                    privateChat: widget.privateChat,
                                    canNavigate: false,
                                    isGroup: false,
                                    medias: media,
                                    user: widget.user,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder(
                        future: _databaseService.getPrivateMessagesType(
                            widget.privateChat.id!, Type.event),
                        builder: (context, snapshot) {
                          return CupertinoListTile(
                            padding: const EdgeInsets.all(0),
                            title: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.calendar,
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 10),
                                const Text("Events"),
                              ],
                            ),
                            trailing: Row(
                              children: [
                                snapshot.connectionState ==
                                            ConnectionState.waiting ||
                                        snapshot.hasError ||
                                        snapshot.data!.isEmpty
                                    ? const SizedBox()
                                    : Text(
                                        snapshot.data!.length.toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                          color:
                                              CupertinoColors.opaqueSeparator,
                                        ),
                                      ),
                                const SizedBox(width: 10),
                                Icon(
                                  CupertinoIcons.right_chevron,
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                  size: 18,
                                ),
                              ],
                            ),
                            onTap: () {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  snapshot.hasError) {
                                return;
                              }
                              List<Message> events = snapshot.data!;
                              if (widget.canNavigate) {
                                widget.navigateToPage!(ShowEventsPage(
                                  privateChat: widget.privateChat,
                                  events: events,
                                  canNavigate: true,
                                  navigateToPage: widget.navigateToPage,
                                  isGroup: false,
                                  user: widget.user,
                                  databaseService: _databaseService,
                                ));
                                return;
                              }

                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => ShowEventsPage(
                                    privateChat: widget.privateChat,
                                    canNavigate: false,
                                    isGroup: false,
                                    events: events,
                                    user: widget.user,
                                    databaseService: _databaseService,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      FutureBuilder(
                        future: _databaseService.getPrivateMessagesType(
                            widget.privateChat.id!, Type.news),
                        builder: (context, snapshot) {
                          return CupertinoListTile(
                            padding: const EdgeInsets.all(0),
                            title: Row(
                              children: [
                                Icon(
                                  CupertinoIcons.photo_on_rectangle,
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 10),
                                const Text("News"),
                              ],
                            ),
                            trailing: Row(
                              children: [
                                snapshot.connectionState ==
                                            ConnectionState.waiting ||
                                        snapshot.hasError ||
                                        snapshot.data!.isEmpty
                                    ? const SizedBox()
                                    : Text(
                                        snapshot.data!.length.toString(),
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.normal,
                                          color:
                                              CupertinoColors.opaqueSeparator,
                                        ),
                                      ),
                                const SizedBox(width: 10),
                                Icon(
                                  CupertinoIcons.right_chevron,
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                  size: 18,
                                ),
                              ],
                            ),
                            onTap: () {
                              if (snapshot.connectionState ==
                                      ConnectionState.waiting ||
                                  snapshot.hasError) {
                                return;
                              }
                              List<Message> news = snapshot.data!;
                              if (widget.canNavigate) {
                                widget.navigateToPage!(ShowNewsPage(
                                  privateChat: widget.privateChat,
                                  news: news,
                                  canNavigate: true,
                                  navigateToPage: widget.navigateToPage,
                                  isGroup: false,
                                  user: widget.user,
                                ));
                                return;
                              }

                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => ShowNewsPage(
                                    privateChat: widget.privateChat,
                                    canNavigate: false,
                                    isGroup: false,
                                    news: news,
                                    user: widget.user,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
