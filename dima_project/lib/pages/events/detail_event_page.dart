import 'package:dima_project/models/event.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/event_service.dart';
import 'package:dima_project/widgets/home/show_event_members.dart';
import 'package:dima_project/widgets/show_date.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';

class DetailPage extends StatefulWidget {
  final Event event;
  final String uuid;
  final Details detail;
  const DetailPage(
      {super.key,
      required this.event,
      required this.detail,
      required this.uuid});
  @override
  DetailPageState createState() => DetailPageState();
}

class DetailPageState extends State<DetailPage> {
  int _isJoining = 0;
  @override
  void initState() {
    _checkJoin();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemPink,
        middle: const Text('Detail Page'),
        trailing: widget.event.admin == widget.uuid
            ? CupertinoButton(
                padding: EdgeInsets.zero,
                child: const Icon(CupertinoIcons.trash,
                    color: CupertinoColors.white),
                onPressed: () async {
                  // Show confirmation dialog
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Delete Event'),
                      content: const Text(
                          'Are you sure you want to delete this event?'),
                      actions: <Widget>[
                        CupertinoDialogAction(
                          child: const Text('Cancel'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        CupertinoDialogAction(
                          child: const Text('Delete'),
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await DatabaseService.deleteDetail(
                                widget.event.id!, widget.detail.id!);
                            if (context.mounted) {
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ],
                    ),
                  );

                  // If the user confirmed, proceed with deletion
                },
              )
            : null,
        leading: Navigator.canPop(context)
            ? CupertinoNavigationBarBackButton(
                color: CupertinoColors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ShowDate(
                  date: widget.detail.startDate!,
                  time: widget.detail.startTime!),
              const Text(
                ' - ',
              ),
              ShowDate(
                  date: widget.detail.endDate!, time: widget.detail.endTime!)
            ],
          ),
          FutureBuilder(
              future: EventService.getAddressFromLatLng(widget.detail.latlng!),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final address = snapshot.data as String;
                  return Text(
                    'Location: $address',
                    style: const TextStyle(
                      fontSize: 16,
                    ),
                  );
                } else {
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
              }),
          SizedBox(
            height: 200,
            width: MediaQuery.of(context).size.width * 0.9,
            child: FlutterMap(
                options: MapOptions(
                  initialCenter: widget.detail.latlng!,
                  initialZoom: 11,
                  interactionOptions:
                      const InteractionOptions(flags: InteractiveFlag.all),
                ),
                children: [
                  openStreetMapTileLayer,
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: widget.detail.latlng!,
                        child: Icon(
                          CupertinoIcons.location_solid,
                          color: CupertinoTheme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ]),
          ),
          const SizedBox(height: 20),
          Text(
            widget.detail.members!.length.toString(),
            style: CupertinoTheme.of(context).textTheme.textStyle,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => ShowEventMembersPage(
                    uuid: widget.uuid,
                    eventId: widget.event.id!,
                    detailId: widget.detail.id!,
                    admin: widget.event.admin,
                  ),
                ),
              );
            },
            child: Text(
              widget.detail.members!.length > 1
                  ? " Participants"
                  : " Participant",
              style: CupertinoTheme.of(context)
                  .textTheme
                  .textStyle
                  .copyWith(color: CupertinoColors.systemGrey),
            ),
          ),
          const SizedBox(height: 20),
          if (widget.event.admin != widget.uuid &&
              DateTime.now().isBefore(DateTime(
                widget.detail.startDate!.year,
                widget.detail.startDate!.month,
                widget.detail.startDate!.day,
                widget.detail.startTime!.hour,
                widget.detail.startTime!.minute,
              )))
            CupertinoButton.filled(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
              onPressed: () async {
                debugPrint('Joining event');
                await DatabaseService.toggleEventJoin(
                    widget.event.id!, widget.detail.id!, widget.uuid);
              },
              child: Text(
                _isJoining == 0
                    ? "Subscribe"
                    : _isJoining == 1
                        ? "Unsubscribe"
                        : "Requested",
              ),
            ),
        ],
      ),
    );
  }

  _checkJoin() async {
    // Listen for updates on the isFollowing stream
    final isJoiningStream = DatabaseService.isJoining(
      widget.uuid,
      widget.event.id!,
      widget.detail.id!,
    );

    // Listen for updates and update _isFollowing accordingly
    await for (final isJoining in isJoiningStream) {
      if (mounted) {
        setState(() {
          _isJoining = isJoining;
        });
      }
    }
  }

  TileLayer get openStreetMapTileLayer => TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'polimi.dima_project.agorapp',
      );
}
