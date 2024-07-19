import 'package:dima_project/models/message.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/news/blog_tile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ShowNewsPage extends StatefulWidget {
  final String id;
  final bool isGroup;

  const ShowNewsPage({super.key, required this.id, required this.isGroup});

  @override
  ShowNewsPageState createState() => ShowNewsPageState();
}

class ShowNewsPageState extends State<ShowNewsPage> {
  Stream<List<dynamic>>? _mediaStream;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    if (widget.isGroup) {
      _mediaStream = DatabaseService.getGroupMessagesType(widget.id, Type.news);
    } else {
      _mediaStream =
          DatabaseService.getPrivateMessagesType(widget.id, Type.news);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _mediaStream == null
        ? const Center(child: CupertinoActivityIndicator())
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
                middle: Text(
                  'News',
                  style: TextStyle(
                      fontSize: 18,
                      color: CupertinoTheme.of(context).primaryColor),
                ),
                leading: CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  padding: const EdgeInsets.only(left: 10),
                  child: Icon(CupertinoIcons.back,
                      color: CupertinoTheme.of(context).primaryColor),
                )),
            child: SafeArea(
              child: StreamBuilder<List<dynamic>>(
                stream: _mediaStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List medias = snapshot.data!
                        .map((doc) => Message.fromSnapshot(doc, widget.id,
                            FirebaseAuth.instance.currentUser!.uid))
                        .toList();
                    final groupedMedias = _groupMediasByDate(medias);

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
                              color: CupertinoTheme.of(context)
                                  .primaryContrastingColor,
                              child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      dateKey,
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle
                                            .color,
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
                                final List<String> news =
                                    message.content.split('\n');
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
                  }
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                },
              ),
            ),
          );
  }

  Map<String, List<Message>> _groupMediasByDate(List<dynamic> medias) {
    Map<String, List<Message>> groupedMedias = {};

    for (var media in medias) {
      final DateTime messageDate =
          DateTime.fromMillisecondsSinceEpoch(media.time.seconds * 1000);

      // Format the date
      final String dateKey = DateUtil.formatDateBasedOnToday(messageDate);

      if (groupedMedias.containsKey(dateKey)) {
        groupedMedias[dateKey]!.add(media);
      } else {
        groupedMedias[dateKey] = [media];
      }
    }

    return groupedMedias;
  }
}
