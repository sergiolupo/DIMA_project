import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chats/groups/group_info_page.dart';
import 'package:dima_project/pages/chats/media_view_page.dart';
import 'package:dima_project/pages/chats/private_chats/private_info_page.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:flutter/cupertino.dart';

class ShowMediasPage extends StatefulWidget {
  final bool isGroup;
  final List<Message> medias;
  final bool canNavigate;
  final Function? navigateToPage;
  final Group? group;
  final PrivateChat? privateChat;
  final UserData? user;
  const ShowMediasPage(
      {super.key,
      required this.isGroup,
      required this.medias,
      required this.canNavigate,
      this.privateChat,
      this.user,
      this.group,
      this.navigateToPage});

  @override
  ShowMediasPageState createState() => ShowMediasPageState();
}

class ShowMediasPageState extends State<ShowMediasPage> {
  late List<Message> _medias;

  @override
  void initState() {
    _medias = widget.medias;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: Text(
            'Medias',
            style: TextStyle(
                fontSize: 18, color: CupertinoTheme.of(context).primaryColor),
          ),
          leading: CupertinoButton(
            onPressed: () {
              if (widget.canNavigate) {
                if (widget.isGroup) {
                  widget.navigateToPage!(GroupInfoPage(
                      group: widget.group!,
                      canNavigate: widget.canNavigate,
                      navigateToPage: widget.navigateToPage));
                } else {
                  widget.navigateToPage!(PrivateInfoPage(
                    privateChat: widget.privateChat!,
                    canNavigate: widget.canNavigate,
                    navigateToPage: widget.navigateToPage,
                    user: widget.user!,
                  ));
                }
              } else {
                Navigator.of(context).pop();
              }
            },
            padding: const EdgeInsets.only(left: 10),
            child: Icon(CupertinoIcons.back,
                color: CupertinoTheme.of(context).primaryColor),
          )),
      child: SafeArea(
        child: Builder(
          builder: (context) {
            final groupedMedias = DateUtils.groupMediasByDate(_medias);
            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: groupedMedias.keys.length,
              itemBuilder: (context, index) {
                String dateKey = groupedMedias.keys.elementAt(index);
                List<Message> mediasForDate = groupedMedias[dateKey]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      color: CupertinoColors.black.withOpacity(0.1),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              dateKey,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CupertinoColors.systemPink,
                              ),
                            ),
                          ]),
                    ),
                    const SizedBox(height: 10),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                      ),
                      itemCount: mediasForDate.length,
                      itemBuilder: (context, index) {
                        final message = mediasForDate[index];
                        return GestureDetector(
                          child: Container(
                            width: 100,
                            height: 100,
                            color: CupertinoColors.lightBackgroundGray,
                            child: CachedNetworkImage(
                              imageUrl: message.content,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CupertinoActivityIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(CupertinoIcons.photo_fill),
                            ),
                          ),
                          onTap: () {
                            if (widget.canNavigate) {
                              widget.navigateToPage!(MediaViewPage(
                                isGroup: widget.isGroup,
                                group: widget.group,
                                privateChat: widget.privateChat,
                                canNavigate: widget.canNavigate,
                                navigateToPage: widget.navigateToPage,
                                media: message,
                                messages: groupedMedias.values
                                    .expand((element) => element)
                                    .toList(),
                              ));
                            } else {
                              Navigator.of(context).push(
                                CupertinoPageRoute(
                                  builder: (context) => MediaViewPage(
                                    isGroup: widget.isGroup,
                                    group: widget.group,
                                    privateChat: widget.privateChat,
                                    canNavigate: widget.canNavigate,
                                    navigateToPage: widget.navigateToPage,
                                    media: message,
                                    messages: groupedMedias.values
                                        .expand((element) => element)
                                        .toList(),
                                  ),
                                ),
                              );
                            }
                          },
                        );
                      },
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
