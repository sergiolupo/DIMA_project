import 'package:dima_project/models/message.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class ShowEventsPage extends StatefulWidget {
  final String id;
  final bool isGroup;

  const ShowEventsPage({super.key, required this.id, required this.isGroup});

  @override
  ShowEventsPageState createState() => ShowEventsPageState();
}

class ShowEventsPageState extends State<ShowEventsPage> {
  Stream<List<dynamic>>? _mediaStream;

  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    if (widget.isGroup) {
      _mediaStream =
          DatabaseService.getGroupMessagesType(widget.id, Type.event);
    } else {
      _mediaStream =
          DatabaseService.getPrivateMessagesType(widget.id, Type.event);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _mediaStream == null
        ? const Center(child: CupertinoActivityIndicator())
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                backgroundColor: CupertinoColors.systemPink,
                middle: const Text('Events'),
                leading: CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  padding: const EdgeInsets.only(left: 10),
                  color: CupertinoColors.systemPink,
                  child: const Icon(CupertinoIcons.back),
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
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: mediasForDate.length,
                              itemBuilder: (context, index) {
                                final message = mediasForDate[index];
                                return FutureBuilder(
                                  future:
                                      DatabaseService.getEvent(message.content),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return const CupertinoActivityIndicator();
                                    }
                                    if (snapshot.hasError) {
                                      return Text('Error: ${snapshot.error}');
                                    }
                                    final event = snapshot.data;
                                    return GestureDetector(
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          child: Row(
                                            children: [
                                              CreateImageWidget.getEventImage(
                                                  event!.imagePath!),
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Container(
                                                    constraints: BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.6),
                                                    child: Text(
                                                      event.name,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 18,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    constraints: BoxConstraints(
                                                        maxWidth: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.6),
                                                    child: Text(
                                                      event.description,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            CupertinoPageRoute(
                                              builder: (context) => EventPage(
                                                uuid: FirebaseAuth
                                                    .instance.currentUser!.uid,
                                                eventId: event.id!,
                                              ),
                                            ),
                                          );
                                        });
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
