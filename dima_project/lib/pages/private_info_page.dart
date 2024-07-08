import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/show_medias_page.dart';
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
  UserData? _user;
  @override
  void initState() {
    super.initState();
    getMembers();
    init();
  }

  void getMembers() {
    _numberOfMediaStream =
        DatabaseService.getPrivateChatMedia(widget.privateChat.id!).map(
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
    return _user == null || _numberOfMediaStream == null
        ? const CupertinoActivityIndicator()
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              leading: CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(CupertinoIcons.back,
                    color: CupertinoColors.white),
              ),
              middle: const Text("Private Chat Info"),
              backgroundColor: CupertinoTheme.of(context).primaryColor,
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
                        decoration: const BoxDecoration(
                          color: CupertinoColors.white,
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                CreateImageWidget.getUserImage(
                                    _user!.imagePath!,
                                    small: true),
                                const SizedBox(width: 20),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
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
                                  title: const Row(
                                    children: [
                                      Icon(
                                        CupertinoIcons.photo_on_rectangle,
                                        color: CupertinoColors.black,
                                      ),
                                      SizedBox(width: 10),
                                      Text("Media"),
                                    ],
                                  ),
                                  trailing: Row(
                                    children: [
                                      int.parse(media.toString()) > 0
                                          ? ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Container(
                                                color:
                                                    CupertinoTheme.of(context)
                                                        .primaryColor,
                                                child: Text(
                                                  media.toString(),
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color:
                                                        CupertinoColors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : const SizedBox(),
                                      const SizedBox(width: 10),
                                      const Icon(
                                        CupertinoIcons.right_chevron,
                                        color: CupertinoColors.black,
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
