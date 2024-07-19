import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/media_view_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ShowMediasPage extends StatefulWidget {
  final String id;
  final bool isGroup;

  const ShowMediasPage({super.key, required this.id, required this.isGroup});

  @override
  ShowMediasPageState createState() => ShowMediasPageState();
}

class ShowMediasPageState extends State<ShowMediasPage> {
  Stream<List<dynamic>>? _mediaStream;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    if (widget.isGroup) {
      _mediaStream =
          DatabaseService.getGroupMessagesType(widget.id, Type.image);
    } else {
      _mediaStream =
          DatabaseService.getPrivateMessagesType(widget.id, Type.image);
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
                  'Medias',
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
                                    Navigator.of(context).push(
                                      CupertinoPageRoute(
                                        builder: (context) => MediaViewPage(
                                          media: message,
                                          messages: groupedMedias.values
                                              .expand((element) => element)
                                              .toList(),
                                        ),
                                      ),
                                    );
                                  },
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
