import 'package:dima_project/services/event_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationPage extends StatefulWidget {
  final LatLng? initialLocation;
  const LocationPage({super.key, required this.initialLocation});

  @override
  LocationPageState createState() => LocationPageState();
}

class LocationPageState extends State<LocationPage> {
  LatLng? selectedLocation;
  @override
  void initState() {
    initPosition();
    super.initState();
  }

  initPosition() async {
    if (widget.initialLocation != null) {
      setState(() {
        selectedLocation = widget.initialLocation;
      });
    } else {
      LatLng pos = await EventService.getCurrentLocation();
      setState(() {
        selectedLocation = pos;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return selectedLocation == null
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
                      initialCenter: selectedLocation!,
                      initialZoom: 11,
                      interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all & ~InteractiveFlag.rotate),
                      onTap: (tapPosition, point) {
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
                        child: const Text(
                          'Select location',
                          style: TextStyle(color: CupertinoColors.white),
                        ),
                      ),
                    ),
                  ),
              ],
            ));
  }

  TileLayer get openStreetMapTileLayer => TileLayer(
        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
        userAgentPackageName: 'polimi.dima_project.agorapp',
      );
}
