import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:flutter/cupertino.dart';

class MediaViewPage extends StatefulWidget {
  final Message media;
  final List<Message> messages;

  const MediaViewPage({super.key, required this.media, required this.messages});

  @override
  MediaViewPageState createState() => MediaViewPageState();
}

class MediaViewPageState extends State<MediaViewPage> {
  late PageController _pageController;
  late int initialPage;

  @override
  void initState() {
    super.initState();
    initialPage =
        widget.messages.indexWhere((message) => message.id == widget.media.id);
    _pageController = PageController(initialPage: initialPage);
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
                onPressed: () => Navigator.of(context).pop(),
                padding: const EdgeInsets.only(left: 10),
                child: Icon(CupertinoIcons.back,
                    color:
                        CupertinoTheme.of(context).textTheme.textStyle.color),
              ),
              middle: SingleChildScrollView(
                child: FutureBuilder<UserData>(
                  future: DatabaseService.getUserData(message.sender),
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
      color: CupertinoColors.black,
      child: Stack(
        children: [
          Center(
            child: CachedNetworkImage(
              imageUrl: message.content,
              fit: BoxFit.cover,
              placeholder: (context, url) => const CupertinoActivityIndicator(),
              errorWidget: (context, url, error) =>
                  const Icon(CupertinoIcons.photo_fill),
            ),
          ),
        ],
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
