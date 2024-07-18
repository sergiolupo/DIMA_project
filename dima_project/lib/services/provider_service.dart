// providers.dart

import 'package:dima_project/models/event.dart';
import 'package:dima_project/models/group.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dima_project/models/user.dart'; // Assuming UserData is defined here
import 'package:dima_project/services/database_service.dart'; // Import your DatabaseService

final userProvider = FutureProvider.family<UserData, String>((ref, uuid) async {
  final userData = await DatabaseService.getUserData(uuid);
  debugPrint('User data: $userData');
  return userData;
});

final followerProvider =
    FutureProvider.family<List<UserData>, String>((ref, uuid) async {
  final followersSnapshot = await DatabaseService.getFollowersUser(uuid);
  final followersList = followersSnapshot.data()!['followers'];

  final List<UserData> followersData = [];
  for (var followerId in followersList) {
    final userData = await DatabaseService.getUserData(followerId);
    followersData.add(userData);
  }

  return followersData;
});

final followingProvider =
    FutureProvider.family<List<UserData>, String>((ref, uuid) async {
  final followingSnapshot = await DatabaseService.getFollowersUser(uuid);
  final followingList = followingSnapshot.data()!['following'];

  final List<UserData> followingData = [];
  for (var followingId in followingList) {
    final userData = await DatabaseService.getUserData(followingId);
    followingData.add(userData);
  }

  return followingData;
});

final groupsProvider =
    FutureProvider.family<List<Group>, String>((ref, uuid) async {
  final groups = await DatabaseService.getGroups(uuid);
  return groups;
});

final joinedEventsProvider =
    FutureProvider.family<List<Event>, String>((ref, uuid) async {
  final events = await DatabaseService.getJoinedEvents(uuid);
  return events;
});

final createdEventsProvider =
    FutureProvider.family<List<Event>, String>((ref, uuid) async {
  final events = await DatabaseService.getCreatedEvents(uuid);
  return events;
});
