import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/pages/groups/group_info_page.dart';
import 'package:dima_project/pages/private_info_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class ShowEventsPage extends StatefulWidget {
  final bool isGroup;
  final List<Message> events;
  final Group? group;
  final Function? navigateToPage;
  final bool canNavigate;
  final PrivateChat? privateChat;
  final UserData? user;
  const ShowEventsPage(
      {super.key,
      required this.isGroup,
      required this.events,
      this.navigateToPage,
      required this.canNavigate,
      this.privateChat,
      this.user,
      this.group});

  @override
  ShowEventsPageState createState() => ShowEventsPageState();
}

class ShowEventsPageState extends State<ShowEventsPage> {
  late List<Message> _events;

  @override
  void initState() {
    _events = widget.events;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: Text(
            'Events',
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
                    navigateToPage: widget.navigateToPage,
                    canNavigate: widget.canNavigate,
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
            final groupedMedias = _groupMediasByDate(_events);

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
                      color: MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? CupertinoTheme.of(context).primaryContrastingColor
                          : CupertinoColors.black.withOpacity(0.1),
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
                        return Container(
                          padding: const EdgeInsets.all(10),
                          child: PhysicalModel(
                            elevation: 3.0,
                            borderRadius: BorderRadius.circular(10),
                            color: CupertinoTheme.of(context)
                                .primaryContrastingColor,
                            child: FutureBuilder(
                              future: DatabaseService.getEvent(message.content),
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
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6),
                                                child: Text(
                                                  maxLines: 1,
                                                  event.name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                constraints: BoxConstraints(
                                                    maxWidth:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.6),
                                                child: Text(
                                                  maxLines: 3,
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
                                            eventId: event.id!,
                                          ),
                                        ),
                                      );
                                    });
                              },
                            ),
                          ),
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
