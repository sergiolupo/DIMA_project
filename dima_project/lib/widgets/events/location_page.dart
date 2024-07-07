import 'package:dima_project/services/event_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  LocationPageState createState() => LocationPageState();
}

class LocationPageState extends State<LocationPage> {
  Position? initialPosition;
  LatLng? selectedLocation;

  @override
  void initState() {
    initPosition();
    super.initState();
  }

  initPosition() async {
    Position pos = await EventService.getCurrentLocation();
    setState(() {
      initialPosition = pos;
    });
  }

  @override
  Widget build(BuildContext context) {
    return initialPosition == null
        ? const CupertinoActivityIndicator()
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              leading: CupertinoButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(CupertinoIcons.back),
              ),
            ),
            child: Stack(
              children: [
                FlutterMap(
                    options: MapOptions(
                      initialCenter: LatLng(initialPosition!.latitude,
                          initialPosition!.longitude),
                      initialZoom: 11,
                      interactionOptions:
                          const InteractionOptions(flags: InteractiveFlag.all),
                      onLongPress: (tapPosition, point) {
                        debugPrint('Tapped on $point');
                        setState(() {
                          selectedLocation = point;
                        });
                      },
                    ),
                    children: [
                      openStreetMapTileLayer,
                      if (selectedLocation != null)
                        MarkerLayer(
                          markers: [
                            Marker(
                              width: 80.0,
                              height: 80.0,
                              point: selectedLocation!,
                              child: Icon(
                                CupertinoIcons.location_solid,
                                color: CupertinoTheme.of(context).primaryColor,
                              ),
                            ),
                          ],
                        ),
                    ]),
                if (selectedLocation != null)
                  Positioned(
                    bottom: 100,
                    left: 100,
                    child: Center(
                      child: CupertinoButton(
                        color: CupertinoTheme.of(context).primaryColor,
                        onPressed: () {
                          Navigator.of(context).pop(selectedLocation);
                        },
                        child: const Text('Select location'),
                      ),
                    ),
                  ),
              ],
            ));
  }

  TileLayer get openStreetMapTileLayer => TileLayer(
        urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'polimi.dima_project.agorapp',
      );
}
