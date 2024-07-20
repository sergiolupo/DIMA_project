import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/show_medias_page.dart';
import 'package:dima_project/pages/show_news_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class PrivateInfoPage extends StatefulWidget {
  final PrivateChat privateChat;
  final String uuid;

  const PrivateInfoPage({
    super.key,
    required this.privateChat,
    required this.uuid,
  });

  @override
  PrivateInfoPageState createState() => PrivateInfoPageState();
}

class PrivateInfoPageState extends State<PrivateInfoPage> {
  Stream<int>? _numberOfMediaStream;
  Stream<int>? _numberOfNewsStream;

  UserData? _user;
  @override
  void initState() {
    super.initState();
    getMembers();
    init();
  }

  void getMembers() {
    _numberOfMediaStream = DatabaseService.getPrivateMessagesTypeStream(
            widget.privateChat.id!, Type.image)
        .map(
      (event) {
        return event.length;
      },
    );
    _numberOfNewsStream = DatabaseService.getPrivateMessagesTypeStream(
            widget.privateChat.id!, Type.news)
        .map(
      (event) {
        return event.length;
      },
    );
  }

  void init() async {
    final user = (await DatabaseService.getUserData(
        widget.uuid == widget.privateChat.members[0]
            ? widget.privateChat.members[1]
            : widget.privateChat.members[0]));
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _user == null ||
            _numberOfMediaStream == null ||
            _numberOfNewsStream == null
        ? const CupertinoActivityIndicator()
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              leading: CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Icon(CupertinoIcons.back,
                    color: CupertinoTheme.of(context).primaryColor),
              ),
              middle: Text("Private Chat Info",
                  style: TextStyle(
                      color: CupertinoTheme.of(context).primaryColor)),
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
                                        _user!.imagePath!,
                                        small: false),
                                    const SizedBox(width: 20),
                                    Text(
                                      _user!.username,
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${_user!.name} ${_user!.surname}",
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
                            StreamBuilder<int>(
                              stream: _numberOfMediaStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CupertinoActivityIndicator();
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                final media = snapshot.data;
                                return CupertinoListTile(
                                  padding: const EdgeInsets.all(0),
                                  title: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.photo_on_rectangle,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text("Media"),
                                    ],
                                  ),
                                  trailing: Row(
                                    children: [
                                      int.parse(media.toString()) > 0
                                          ? Text(
                                              media.toString(),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal,
                                                color: CupertinoColors
                                                    .opaqueSeparator,
                                              ),
                                            )
                                          : const SizedBox(),
                                      const SizedBox(width: 10),
                                      Icon(
                                        CupertinoIcons.right_chevron,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  onTap: () => {
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => ShowMediasPage(
                                          id: widget.privateChat.id!,
                                          isGroup: false,
                                        ),
                                      ),
                                    ),
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            StreamBuilder<int>(
                              stream: _numberOfNewsStream,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CupertinoActivityIndicator();
                                }
                                if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                }
                                final news = snapshot.data;
                                return CupertinoListTile(
                                  padding: const EdgeInsets.all(0),
                                  title: Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.photo_on_rectangle,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                      ),
                                      const SizedBox(width: 10),
                                      const Text("News"),
                                    ],
                                  ),
                                  trailing: Row(
                                    children: [
                                      int.parse(news.toString()) > 0
                                          ? Text(
                                              news.toString(),
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.normal,
                                                color: CupertinoColors
                                                    .opaqueSeparator,
                                              ),
                                            )
                                          : const SizedBox(),
                                      const SizedBox(width: 10),
                                      Icon(
                                        CupertinoIcons.right_chevron,
                                        color: CupertinoTheme.of(context)
                                            .primaryColor,
                                        size: 18,
                                      ),
                                    ],
                                  ),
                                  onTap: () => {
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => ShowNewsPage(
                                          id: widget.privateChat.id!,
                                          isGroup: false,
                                        ),
                                      ),
                                    ),
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
