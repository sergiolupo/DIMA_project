import 'package:dima_project/pages/events/detail_event_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/widgets/image_widget.dart';

import 'package:dima_project/pages/events/edit_event_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EventPage extends ConsumerStatefulWidget {
  final String eventId;

  const EventPage({
    super.key,
    required this.eventId,
  });

  @override
  EventPageState createState() => EventPageState();
}

class EventPageState extends ConsumerState<EventPage> {
  final String uid = AuthService.uid;
  @override
  void initState() {
    ref.read(eventProvider(widget.eventId));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(eventProvider(widget.eventId));
    return Consumer(builder: (context, watch, _) {
      return event.when(
        data: (event) {
          return CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              transitionBetweenRoutes: false,
              backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
              trailing: uid == event.admin
                  ? CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => EditEventPage(
                                      event: event,
                                    )));
                      },
                      child: Text(
                        'Edit',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      ),
                    )
                  : null,
              leading: Navigator.canPop(context)
                  ? CupertinoNavigationBarBackButton(
                      color: CupertinoTheme.of(context).primaryColor,
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    )
                  : null,
              middle: Text(
                'Event',
                style: TextStyle(
                    color: CupertinoTheme.of(context).primaryColor,
                    fontSize: 18),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SafeArea(
                      child: Container(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CreateImageWidget.getEventImage(event.imagePath!),
                            const SizedBox(height: 10),
                            Text(
                              textAlign: TextAlign.start,
                              event.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                                width: MediaQuery.of(context).size.width * 0.9,
                                alignment: Alignment.centerLeft,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    color: CupertinoTheme.of(context)
                                        .primaryContrastingColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Description:',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      event.description,
                                      maxLines: 3,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.normal,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                )),
                            const SizedBox(height: 20),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: event.details!.length,
                              itemBuilder: (BuildContext context, int index) {
                                final detail = event.details![index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: CupertinoTheme.of(context)
                                            .primaryContrastingColor,
                                      ),
                                      child: CupertinoListTile(
                                        leading: Icon(
                                          CupertinoIcons.calendar,
                                          color: CupertinoTheme.of(context)
                                              .primaryColor,
                                        ),
                                        title: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${DateFormat('dd/MM/yyyy').format(detail.startDate!)} - ${DateFormat('dd/MM/yyyy').format(detail.endDate!)}',
                                            ),
                                            FutureBuilder(
                                                future: EventService
                                                    .getAddressFromLatLng(
                                                        detail.latlng!),
                                                builder: (context, snapshot) {
                                                  if (snapshot.hasData &&
                                                      snapshot.data != null) {
                                                    final address =
                                                        snapshot.data as String;
                                                    return Text(
                                                      address,
                                                      style: const TextStyle(
                                                        fontSize: 16,
                                                      ),
                                                    );
                                                  } else {
                                                    return const Center(
                                                      child:
                                                          CupertinoActivityIndicator(),
                                                    );
                                                  }
                                                }),
                                          ],
                                        ),
                                        trailing: DateTime(
                                                    detail.startDate!.year,
                                                    detail.startDate!.month,
                                                    detail.startDate!.day,
                                                    detail.startTime!.hour,
                                                    detail.startTime!.minute)
                                                .isBefore(DateTime.now())
                                            ? const Icon(
                                                CupertinoIcons.circle_fill,
                                                color:
                                                    CupertinoColors.systemRed)
                                            : const Icon(
                                                CupertinoIcons.circle_fill,
                                                color: CupertinoColors
                                                    .systemGreen),
                                        onTap: () {
                                          Navigator.of(context).push(
                                            CupertinoPageRoute(
                                              builder: (context) => DetailPage(
                                                eventId: event.id!,
                                                detailId: detail.id!,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              },
                            ),
                            uid == event.admin
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      CupertinoButton(
                                          child: const Text(
                                            'Delete Event',
                                            style: TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color:
                                                    CupertinoColors.systemRed),
                                          ),
                                          onPressed: () {
                                            showCupertinoDialog(
                                              context: context,
                                              builder: (newContext) =>
                                                  CupertinoAlertDialog(
                                                title:
                                                    const Text('Delete Event'),
                                                content: const Text(
                                                    'Are you sure you want to delete this date?'),
                                                actions: <Widget>[
                                                  CupertinoDialogAction(
                                                    child: const Text('Cancel'),
                                                    onPressed: () =>
                                                        Navigator.of(newContext)
                                                            .pop(),
                                                  ),
                                                  CupertinoDialogAction(
                                                    child: const Text('Delete'),
                                                    onPressed: () async {
                                                      Navigator.of(newContext)
                                                          .pop();
                                                      await DatabaseService
                                                          .deleteEvent(
                                                              widget.eventId);
                                                      ref.invalidate(
                                                          createdEventsProvider(
                                                              uid));
                                                      ref.invalidate(
                                                          joinedEventsProvider(
                                                              uid));
                                                      ref.invalidate(
                                                          eventProvider(
                                                              widget.eventId));
                                                      if (context.mounted) {
                                                        Navigator.of(context)
                                                            .pop();
                                                      }
                                                    },
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                    ],
                                  )
                                : Container(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CupertinoActivityIndicator(),
        ),
        error: (error, stackTrace) {
          return Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            color: CupertinoTheme.of(context).scaffoldBackgroundColor,
            child: MediaQuery.of(context).size.width > Constants.limitWidth
                ? MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Image.asset(
                        'assets/darkMode/event_canceled_tablet.png',
                        fit: BoxFit.cover,
                      )
                    : Image.asset('assets/images/event_canceled_tablet.png',
                        fit: BoxFit.cover)
                : MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Image.asset('assets/darkMode/event_canceled.png',
                        fit: BoxFit.cover)
                    : Image.asset('assets/images/event_canceled.png',
                        fit: BoxFit.cover),
          );
        },
      );
    });
  }
}
