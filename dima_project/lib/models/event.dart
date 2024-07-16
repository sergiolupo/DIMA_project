import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:latlong2/latlong.dart';

class Details {
  DateTime? startDate;
  DateTime? endDate;
  String? location;
  DateTime? startTime;
  DateTime? endTime;
  LatLng? latlng;
  String? id;
  List<String>? members;
  final List<String>? requests;

  Details({
    this.startDate,
    this.endDate,
    this.location,
    this.startTime,
    this.endTime,
    this.latlng,
    this.id,
    this.members,
    this.requests,
  });

  static Map<String, dynamic> toMap(Details details) {
    return {
      'startDate': details.startDate,
      'endDate': details.endDate,
      'location': details.location,
      'startTime': details.startTime,
      'endTime': details.endTime,
      'latlng': GeoPoint(details.latlng!.latitude, details.latlng!.longitude),
      'members': details.members,
      'requests': details.requests ?? [],
    };
  }

  static Details fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    return Details(
      startDate: snapshot['startDate'].toDate(),
      endDate: snapshot['endDate'].toDate(),
      location: snapshot['location'],
      startTime: snapshot['startTime'].toDate(),
      endTime: snapshot['endTime'].toDate(),
      latlng: LatLng(snapshot['latlng'].latitude, snapshot['latlng'].longitude),
      id: snapshot.id,
      members: List<String>.from(snapshot['members']),
      requests: List<String>.from(snapshot['requests']),
    );
  }
}

class Event {
  final String name;
  final String? id;
  final String admin;
  final String? imagePath;
  final String description;
  final List<Details>? details;
  final bool isPublic;

  final bool notify;
  final Timestamp? createdAt;

  Event({
    required this.name,
    this.id,
    required this.admin,
    this.imagePath,
    required this.description,
    required this.isPublic,
    required this.notify,
    this.createdAt,
    this.details,
  });

  static Map<String, dynamic> toMap(Event event) {
    return {
      'eventId': event.id ?? '',
      'name': event.name,
      'admin': event.admin,
      'imagePath': event.imagePath,
      'description': event.description,
      'isPublic': event.isPublic,
      'notify': event.notify,
      'createdAt': event.createdAt,
    };
  }

  static Future<Event> fromSnapshot(DocumentSnapshot documentSnapshot) async {
    var detailsQuery =
        await documentSnapshot.reference.collection('details').get();
    List<Details> details =
        detailsQuery.docs.map((doc) => Details.fromSnapshot(doc)).toList();
    return Event(
      name: documentSnapshot['name'],
      id: documentSnapshot.id,
      admin: documentSnapshot['admin'],
      imagePath: documentSnapshot['imagePath'],
      description: documentSnapshot['description'],
      isPublic: documentSnapshot['isPublic'],
      notify: documentSnapshot['notify'],
      createdAt: documentSnapshot['createdAt'],
      details: details,
    );
  }
}
