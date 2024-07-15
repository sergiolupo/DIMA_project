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
              ShowDate(date: widget.detail.startDate!),
              const Text(
                ' - ',
              ),
              ShowDate(date: widget.detail.endDate!)
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
            widget.event.members.length.toString(),
            style: CupertinoTheme.of(context).textTheme.textStyle,
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                CupertinoPageRoute(
                  builder: (context) => ShowEventMembersPage(
                    uuid: widget.uuid,
                    eventId: widget.event.id!,
                  ),
                ),
              );
            },
            child: Text(
              widget.event.members.length > 1
                  ? " Participants"
                  : " Participant",
              style: CupertinoTheme.of(context)
                  .textTheme
                  .textStyle
                  .copyWith(color: CupertinoColors.systemGrey),
            ),
          ),
          const SizedBox(height: 20),
          CupertinoButton.filled(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 8),
            onPressed: () async {
              await DatabaseService.toggleEventJoin(
                  widget.event.id!, widget.uuid);
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
