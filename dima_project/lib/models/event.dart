import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Details {
  DateTime? startDate;
  DateTime? endDate;
  String? location;
  DateTime? startTime;
  DateTime? endTime;
  LatLng? latlng;
  Details({
    this.startDate,
    this.endDate,
    this.location,
    this.startTime,
    this.endTime,
    this.latlng,
  });
}

class Event {
  final String name;
  final String? id;
  final String admin;
  final String? imagePath;
  final String description;
  final List<Details> details;
  final List<String> members;
  final bool isPublic;
  final List<String>? requests;

  final bool notify;
  final Timestamp? createdAt;

  Event({
    required this.name,
    this.id,
    required this.admin,
    this.imagePath,
    required this.description,
    required this.details,
    required this.members,
    required this.isPublic,
    this.requests,
    required this.notify,
    this.createdAt,
  });

  static Map<String, dynamic> toMap(Event event) {
    return {
      'eventId': event.id ?? '',
      'name': event.name,
      'admin': event.admin,
      'imagePath': event.imagePath,
      'description': event.description,
      'details': event.details
          .map((detail) => {
                'startDate': detail.startDate,
                'endDate': detail.endDate,
                'latlng':
                    GeoPoint(detail.latlng!.latitude, detail.latlng!.longitude),
                'startTime': detail.startTime,
                'endTime': detail.endTime,
              })
          .toList(),
      'members': event.members,
      'isPublic': event.isPublic,
      'requests': event.requests ?? [],
      'notify': event.notify,
      'createdAt': event.createdAt,
    };
  }

  static Event fromSnapshot(DocumentSnapshot documentSnapshot) {
    return Event(
      name: documentSnapshot['name'],
      id: documentSnapshot.id,
      admin: documentSnapshot['admin'],
      imagePath: documentSnapshot['imagePath'],
      description: documentSnapshot['description'],
      members: List<String>.from(documentSnapshot['members']),
      isPublic: documentSnapshot['isPublic'],
      requests: List<String>.from(documentSnapshot['requests']),
      details: List<Details>.from(
        documentSnapshot['details'].map(
          (detail) => Details(
            startDate: detail['startDate']?.toDate(),
            endDate: detail['endDate']?.toDate(),
            latlng: LatLng(
              detail['latlng'].latitude,
              detail['latlng'].longitude,
            ),
            startTime: detail['startTime']?.toDate(),
            endTime: detail['endTime']?.toDate(),
          ),
        ),
      ),
      notify: documentSnapshot['notify'],
      createdAt: documentSnapshot['createdAt'],
    );
  }
}
