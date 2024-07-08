import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Event {
  final String name;
  final String? id;
  final String admin;
  final String? imagePath;
  final String description;

  final List<String> members;
  final bool isPublic;
  final List<String>? requests;
  final DateTime startDate;
  final DateTime endDate;
  final LatLng location;
  final bool notify;
  Event({
    required this.name,
    this.id,
    required this.admin,
    this.imagePath,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.members,
    required this.isPublic,
    this.requests,
    required this.location,
    required this.notify,
  });

  static Map<String, dynamic> toMap(Event event) {
    return {
      'eventId': event.id ?? '',
      'name': event.name,
      'admin': event.admin,
      'imagePath': event.imagePath,
      'description': event.description,
      'startDate': event.startDate,
      'endDate': event.endDate,
      'members': event.members,
      'isPublic': event.isPublic,
      'requests': event.requests ?? [],
      'location': GeoPoint(event.location.latitude, event.location.longitude),
      'notify': event.notify,
    };
  }

  static Event fromSnapshot(DocumentSnapshot documentSnapshot) {
    return Event(
      name: documentSnapshot['name'],
      id: documentSnapshot.id,
      admin: documentSnapshot['admin'],
      imagePath: documentSnapshot['imagePath'],
      description: documentSnapshot['description'],
      startDate: (documentSnapshot['startDate'] as Timestamp).toDate(),
      endDate: (documentSnapshot['endDate'] as Timestamp).toDate(),
      members: List<String>.from(documentSnapshot['members']),
      isPublic: documentSnapshot['isPublic'],
      requests: List<String>.from(documentSnapshot['requests']),
      location: LatLng(
        documentSnapshot['location'].latitude,
        documentSnapshot['location'].longitude,
      ),
      notify: documentSnapshot['notify'],
    );
  }
}
