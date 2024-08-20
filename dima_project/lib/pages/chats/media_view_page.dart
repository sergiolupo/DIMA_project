import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chats/show_medias_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:flutter/cupertino.dart';

class MediaViewPage extends StatefulWidget {
  final Message media;
  final List<Message> messages;
  final bool canNavigate;
  final Function? navigateToPage;
  final bool isGroup;
  final Group? group;
  final PrivateChat? privateChat;
  final DatabaseService databaseService;
  final NotificationService notificationService;
  const MediaViewPage(
      {super.key,
      required this.media,
      required this.messages,
      required this.canNavigate,
      required this.isGroup,
      this.privateChat,
      this.group,
      this.navigateToPage,
      required this.databaseService,
      required this.notificationService});

  @override
  MediaViewPageState createState() => MediaViewPageState();
}

class MediaViewPageState extends State<MediaViewPage> {
  late PageController _pageController;
  late int initialPage;
  late final DatabaseService _databaseService;
  @override
  void initState() {
    _databaseService = widget.databaseService;

    initialPage =
        widget.messages.indexWhere((message) => message.id == widget.media.id);
    _pageController = PageController(initialPage: initialPage);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      controller: _pageController,
      itemCount: widget.messages.length,
      itemBuilder: (context, index) {
        final message = widget.messages[index];
        return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
              leading: CupertinoButton(
                onPressed: () {
                  if (widget.canNavigate) {
                    widget.navigateToPage!(ShowMediasPage(
                        isGroup: widget.isGroup,
                        medias: widget.messages,
                        canNavigate: widget.canNavigate,
                        group: widget.group,
                        privateChat: widget.privateChat,
                        navigateToPage: widget.navigateToPage,
                        databaseService: _databaseService,
                        notificationService: widget.notificationService));

                    return;
                  }
                  Navigator.of(context).pop();
                },
                padding: const EdgeInsets.only(left: 10),
                child: Icon(CupertinoIcons.back,
                    color:
                        CupertinoTheme.of(context).textTheme.textStyle.color),
              ),
              middle: SingleChildScrollView(
                child: FutureBuilder<UserData>(
                  future: _databaseService.getUserData(message.sender),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CupertinoActivityIndicator());
                    } else if (snapshot.hasError) {
                      return _buildUserInfoRow(
                        'Account Deleted',
                        message.time.microsecondsSinceEpoch.toString(),
                      );
                    } else if (snapshot.hasData) {
                      final user = snapshot.data!;
                      return _buildUserInfoRow(user.username,
                          message.time.microsecondsSinceEpoch.toString());
                    } else {
                      return Container();
                    }
                  },
                ),
              ),
            ),
            child: _buildMediaView(message));
      },
    );
  }

  Widget _buildMediaView(Message message) {
    return Container(
      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: CachedNetworkImage(
          imageUrl: message.content,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) =>
              const Icon(CupertinoIcons.photo_fill),
          errorListener: (value) {},
        ),
      ),
    );
  }

  Widget _buildUserInfoRow(String username, String timestamp) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.6,
          ),
          child: Text(
            overflow: TextOverflow.ellipsis,
            username,
            style: TextStyle(
              color: CupertinoTheme.of(context).textTheme.textStyle.color,
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          DateUtil.getFormattedDateAndTime(context: context, time: timestamp),
          style: TextStyle(
            color: CupertinoTheme.of(context).textTheme.textStyle.color,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}
