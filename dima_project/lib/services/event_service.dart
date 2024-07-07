import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EventService {
  static Future<LatLng> getCurrentLocation() async {
    // Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, handle accordingly
      throw Exception('Location services are disabled.');
    }

    // Check for location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        // Permission is denied, handle accordingly
        throw Exception('Location permission is denied.');
      }
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return LatLng(position.latitude, position.longitude);
  }

  static Future<String?> getAddressFromLatLng(LatLng latLng) async {
    final url =
        'https://nominatim.openstreetmap.org/reverse?format=json&lat=${latLng.latitude}&lon=${latLng.longitude}';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final address = data['address'];
      if (address != null) {
        final road = address['road'] ?? '';
        final city =
            address['city'] ?? address['town'] ?? address['village'] ?? '';
        final country = address['country'] ?? '';

        return [road, city, country]
            .where((part) => part.isNotEmpty)
            .join(', ');
      }
      return data['display_name'] as String?;
    } else {
      debugPrint('Failed to fetch address: ${response.statusCode}');
      return null;
    }
  }
}
