import 'package:flutter/cupertino.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
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
        final houseNumber = address['house_number'] ?? '';
        final road = address['road'] ?? '';
        final city =
            address['city'] ?? address['town'] ?? address['village'] ?? '';
        final country = address['country'] ?? '';

        return [road, houseNumber, city, country]
            .where((part) => part.isNotEmpty)
            .join(', ');
      }
      return data['display_name'] as String?;
    } else {
      debugPrint('Failed to fetch address: ${response.statusCode}');
      return null;
    }
  }

  static bool validateForm(
      BuildContext context,
      String name,
      String description,
      String location,
      DateTime startDate,
      DateTime endDate,
      DateTime startTime,
      DateTime endTime) {
    if (name.isEmpty) {
      _showErrorDialog(context, 'Event name is required');
      return false;
    }
    if (description.isEmpty) {
      _showErrorDialog(context, 'Event description is required');
      return false;
    }
    if (DateFormat('dd/MM/yyyy').format(startDate).isEmpty) {
      _showErrorDialog(context, 'Event start date is required');
      return false;
    }
    if (DateFormat('dd/MM/yyyy').format(endDate).isEmpty) {
      _showErrorDialog(context, 'Event end date is required');
      return false;
    }
    if (DateFormat('HH:mm').format(startTime).isEmpty) {
      _showErrorDialog(context, 'Event start time is required');
      return false;
    }
    if (DateFormat('HH:mm').format(endTime).isEmpty) {
      _showErrorDialog(context, 'Event end time is required');
      return false;
    }
    if (location.isEmpty) {
      _showErrorDialog(context, 'Event location is required');
      return false;
    }
    if (_isEventInThePast(startDate, startTime)) {
      _showErrorDialog(context, 'Event cannot be scheduled in the past');
      return false;
    }
    if (!_isStartDateBeforeEndDate(startDate, endDate, startTime, endTime)) {
      _showErrorDialog(context, 'Event start date must be before end date');
      return false;
    }
    return true;
  }

  static bool _isStartDateBeforeEndDate(DateTime startDate, DateTime endDate,
      DateTime startTime, DateTime endTime) {
    final startDateTime = DateTime(startDate.year, startDate.month,
        startDate.day, startTime.hour, startTime.minute);
    final endDateTime = DateTime(
        endDate.year, endDate.month, endDate.day, endTime.hour, endTime.minute);
    return startDateTime.isBefore(endDateTime);
  }

  static bool _isEventInThePast(DateTime startDate, DateTime startTime) {
    final now = DateTime.now();
    final eventDateTime = DateTime(startDate.year, startDate.month,
        startDate.day, startTime.hour, startTime.minute);
    return eventDateTime.isBefore(now);
  }

  static void _showErrorDialog(BuildContext context, String message) {
    showCupertinoDialog(
      context: context,
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: const Text('Validation Error'),
          content: Text(message),
          actions: <Widget>[
            CupertinoDialogAction(
              isDefaultAction: true,
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
