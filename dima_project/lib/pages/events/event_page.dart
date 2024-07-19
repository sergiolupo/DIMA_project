import 'package:dima_project/pages/events/detail_event_page.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/widgets/image_widget.dart';

import 'package:dima_project/pages/events/edit_event_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

class EventPage extends ConsumerStatefulWidget {
  final String uuid;
  final String eventId;

  const EventPage({super.key, required this.eventId, required this.uuid});

  @override
  EventPageState createState() => EventPageState();
}

class EventPageState extends ConsumerState<EventPage> {
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
              backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
              trailing: widget.uuid == event.admin
                  ? CupertinoButton(
                      padding: const EdgeInsets.all(0),
                      onPressed: () {
                        Navigator.push(
                            context,
                            CupertinoPageRoute(
                                builder: (context) => EditEventPage(
                                      event: event,
                                      uuid: widget.uuid,
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
            child: SafeArea(
              child: Container(
                height: MediaQuery.of(context).size.height * 0.7,
                padding: const EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CreateImageWidget.getEventImage(event.imagePath!),
                        const SizedBox(width: 50),
                      ],
                    ),
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
                            color: CupertinoColors.lightBackgroundGray,
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
                      shrinkWrap: true,
                      itemCount: event.details!.length,
                      itemBuilder: (BuildContext context, int index) {
                        final detail = event.details![index];
                        return Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: CupertinoColors.extraLightBackgroundGray,
                              ),
                              child: CupertinoListTile(
                                leading: const Icon(
                                  CupertinoIcons.calendar,
                                  color: CupertinoColors.systemPink,
                                ),
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${DateFormat('dd/MM/yyyy').format(detail.startDate!)} - ${DateFormat('dd/MM/yyyy').format(detail.endDate!)}',
                                    ),
                                    FutureBuilder(
                                        future:
                                            EventService.getAddressFromLatLng(
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
                                trailing: const Icon(CupertinoIcons.forward),
                                onTap: () {
                                  Navigator.of(context).push(
                                    CupertinoPageRoute(
                                      builder: (context) => DetailPage(
                                        event: event,
                                        detail: detail,
                                        uuid: widget.uuid,
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
                  ],
                ),
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CupertinoActivityIndicator(),
        ),
        error: (error, stackTrace) {
          return Center(
            child: Text('Error: $error'),
          );
        },
      );
    });
  }
}
