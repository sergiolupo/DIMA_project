import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chats/groups/group_info_page.dart';
import 'package:dima_project/pages/chats/private_chats/private_info_page.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/news/blog_tile.dart';
import 'package:flutter/cupertino.dart';

class ShowNewsPage extends StatefulWidget {
  final bool isGroup;
  final List<Message> news;
  final Group? group;
  final bool canNavigate;
  final Function? navigateToPage;
  final PrivateChat? privateChat;
  final UserData? user;
  const ShowNewsPage(
      {super.key,
      required this.isGroup,
      required this.news,
      this.group,
      this.user,
      required this.canNavigate,
      this.privateChat,
      this.navigateToPage});

  @override
  ShowNewsPageState createState() => ShowNewsPageState();
}

class ShowNewsPageState extends State<ShowNewsPage> {
  late List<Message> _news;

  @override
  void initState() {
    _news = widget.news;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: Text(
            'News',
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
              }
            },
            padding: const EdgeInsets.only(left: 10),
            child: Icon(CupertinoIcons.back,
                color: CupertinoTheme.of(context).primaryColor),
          )),
      child: SafeArea(
        child: Builder(
          builder: (context) {
            final groupedMedias = DateUtil.groupMediasByDate(_news);

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
                      color: CupertinoTheme.of(context).primaryContrastingColor,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              dateKey,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: CupertinoTheme.of(context).primaryColor,
                              ),
                            ),
                          ]),
                    ),
                    const SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: mediasForDate.length,
                      itemBuilder: (context, index) {
                        final message = mediasForDate[index];
                        final List<String> news = message.content.split('\n');
                        return BlogTile(
                          url: news[2],
                          description: news[1],
                          imageUrl: news[3],
                          title: news[0],
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
