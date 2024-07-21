import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/events/event_page.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/widgets/show_date.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowEvent extends ConsumerStatefulWidget {
  final String uuid;
  final String eventId;
  final UserData userData;
  final bool createdEvents;
  const ShowEvent({
    super.key,
    required this.uuid,
    required this.eventId,
    required this.userData,
    required this.createdEvents,
  });

  @override
  ShowEventState createState() => ShowEventState();
}

class ShowEventState extends ConsumerState<ShowEvent> {
  PageController? _pageController;

  @override
  void initState() {
    super.initState();
    ref.read(joinedEventsProvider(widget.uuid));
    ref.read(createdEventsProvider(widget.uuid));
  }

  @override
  void dispose() {
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final events = widget.createdEvents
        ? ref.watch(createdEventsProvider(widget.uuid))
        : ref.watch(joinedEventsProvider(widget.uuid));
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoTheme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      child: events.when(
        data: (events) {
          if (events.isEmpty) {
            return const Center(
              child: Text('No events found'),
            );
          }
          final int initialPage =
              events.indexWhere((event) => event.id == widget.eventId);
          _pageController = PageController(initialPage: initialPage);
          return PageView.builder(
            controller: _pageController,
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            CreateImageWidget.getUserImage(
                                widget.userData.imagePath!,
                                small: true),
                            const SizedBox(width: 10.0),
                            Text(
                              widget.userData.username,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Container(
                              width: 400,
                              height: 400,
                              color: CupertinoColors.white,
                              child: (event.imagePath != null &&
                                      event.imagePath!.isNotEmpty)
                                  ? Image.network(
                                      event.imagePath!,
                                      fit: BoxFit.cover,
                                    )
                                  : Image.asset(
                                      'assets/default_event_image.png',
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Container(
                              margin: const EdgeInsets.only(top: 370),
                              width: 400,
                              child: CupertinoButton.filled(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12, horizontal: 24),
                                borderRadius: BorderRadius.zero,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    CupertinoPageRoute(
                                      builder: (context) => EventPage(
                                        uuid: widget.uuid,
                                        eventId: event.id!,
                                      ),
                                    ),
                                  );
                                },
                                child: const Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Go to Event',
                                      style: TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 18,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10.0,
                                            color: CupertinoColors.black,
                                            offset: Offset(2.0, 2.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(CupertinoIcons.forward,
                                        color: CupertinoColors.white),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20.0),
                        Text(
                          event.name,
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .color,
                          ),
                        ),
                        const SizedBox(height: 10.0),
                        Text(
                          event.description,
                          style: TextStyle(
                            fontSize: 18,
                            color: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .color,
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: event.details!.length,
                          itemBuilder: (context, index) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Transform.scale(
                                        scale: 0.75,
                                        child: ShowDate(
                                            date: event
                                                .details![index].startDate!,
                                            time: event
                                                .details![index].startTime!)),
                                    const Text(' - '),
                                    Transform.scale(
                                        scale: 0.75,
                                        child: ShowDate(
                                            date:
                                                event.details![index].endDate!,
                                            time: event
                                                .details![index].endTime!)),
                                  ],
                                ),
                                FutureBuilder(
                                    future: EventService.getAddressFromLatLng(
                                        event.details![index].latlng!),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        final address = snapshot.data as String;
                                        return Text(
                                          address,
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        );
                                      } else {
                                        return const Center(
                                          child: CupertinoActivityIndicator(),
                                        );
                                      }
                                    })
                              ],
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
        loading: () => const Center(
          child: CupertinoActivityIndicator(),
        ),
        error: (error, stackTrace) {
          debugPrint('Error occurred: $error');
          return const Center(
            child: Text('Error occurred'),
          );
        },
      ),
    );
  }
}
