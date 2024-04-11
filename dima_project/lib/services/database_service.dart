import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:flutter/cupertino.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final groupsRef = _firestore.collection('groups');
  static final usersRef = _firestore.collection('users');
  static final followersRef = _firestore.collection('followers');
  static Future<void> registerUserWithUUID(
      UserData user, String uuid, Uint8List imagePath) async {
    String imageUrl = imagePath.toString() == '[]'
        ? ''
        : await StorageService.uploadImageToStorage(
            'profile_images/$uuid.jpg', imagePath);
    List<Map<String, dynamic>> serializedList =
        user.categories.map((item) => {'value': item}).toList();
    await usersRef.doc(uuid).set({
      'name': user.name,
      'surname': user.surname,
      'username': user.username,
      'email': user.email,
      'imageUrl': imageUrl,
      'selectedCategories': serializedList,
      'groups': [],
    });

    await followersRef.doc(user.username).set({
      'followers': [],
      'following': [],
    });
  }

  static Future<UserData> getUserData(String uid) async {
    DocumentSnapshot documentSnapshot = await usersRef.doc(uid).get();
    UserData user = UserData.convertToUserData(documentSnapshot);
    return user;
  }

  static Future<UserData> getUserDataFromUsername(String username) async {
    username = username.replaceAll('[', '').replaceAll(']', '');

    QuerySnapshot querySnapshot =
        await usersRef.where('username', isEqualTo: username).get();
    DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
    UserData user = UserData.convertToUserData(documentSnapshot);
    return user;
  }

  Future<String> findUUID(String email) async {
    final QuerySnapshot result =
        await usersRef.where('email', isEqualTo: email).get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      return documents[0].id;
    } else {
      return '';
    }
  }

  static Future<bool> checkUserExist(String email) async {
    debugPrint('Checking if user exists... $email');
    final QuerySnapshot result =
        await usersRef.where('email', isEqualTo: email).get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  static Future<List<DocumentSnapshot<Map<String, dynamic>>>> getGroups(
      String uid) async {
    DocumentSnapshot<Map<String, dynamic>> groupsSnapshot =
        await usersRef.doc(uid).get();

    List<Map<String, dynamic>> groups =
        List<Map<String, dynamic>>.from(groupsSnapshot['groups']);

    List<DocumentSnapshot<Map<String, dynamic>>> result = [];
    if (groups.isNotEmpty) {
      for (Map<String, dynamic> groupId in groups) {
        DocumentSnapshot<Map<String, dynamic>> groupDoc =
            await groupsRef.doc(groupId["groupId"]).get();
        result.add(groupDoc);
      }
    }
    return result;
  }

  //create a group
  static Future<void> createGroup(
    Group group,
    String uid,
    Uint8List imagePath,
  ) async {
    try {
      List<Map<String, dynamic>> serializedList =
          group.categories!.map((item) => {'value': item}).toList();

      DocumentReference docRef = await groupsRef.add({
        'groupName': group.name,
        'groupImage': '',
        'admin': group.admin,
        'description': group.description,
        'messages': [],
        'groupId': '',
        'recentMessage': "",
        'recentMessageSender': "",
        "members": FieldValue.arrayUnion([group.admin]),
        "categories": serializedList,
      });

      String imageUrl = imagePath.toString() == '[]'
          ? ''
          : await StorageService.uploadImageToStorage(
              'group_images/${docRef.id}.jpg', imagePath);

      await groupsRef.doc(docRef.id).update({
        'groupId': docRef.id,
        'groupImage': imageUrl,
      });
      DocumentReference userDocumentReference = usersRef.doc(uid);

      return await userDocumentReference.update({
        'groups': FieldValue.arrayUnion([
          {
            'groupId': docRef.id,
          }
        ])
      });
    } catch (e) {
      debugPrint("Error while creating the group: $e");
    }
  }

  static getChats(String groupId) async {
    return groupsRef
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  static Future getGroupAdmin(String groupId) async {
    DocumentSnapshot<Map<String, dynamic>> groupDoc =
        await groupsRef.doc(groupId).get();
    return groupDoc['admin'];
  }

  static Future<Stream<List<DocumentSnapshot<Map<String, dynamic>>>>>
      getGroupMembers(String groupId) {
    return groupsRef.doc(groupId).get().then((groupDoc) {
      return usersRef
          .where('username', whereIn: groupDoc['members'])
          .snapshots()
          .map((querySnapshot) => querySnapshot.docs.toList());
    });
  }

  static searchByGroupNameStream(String searchText) {
    return groupsRef
        .where('groupName', isEqualTo: searchText)
        .where('groupId', isNotEqualTo: '')
        .snapshots();
  }

  static searchByUsernameStream(String searchText) {
    return usersRef.where('username', isEqualTo: searchText).snapshots();
  }

  static isUserJoined(String groupId, String username) async {
    DocumentSnapshot<Map<String, dynamic>> groupDoc =
        await groupsRef.doc(groupId).get();

    List<dynamic> members = groupDoc['members'];
    return members.contains(username);
  }

  static Future toggleGroupJoin(String groupId, String uid, String username) {
    return isUserJoined(groupId, username).then((isJoined) {
      if (isJoined) {
        return Future.wait([
          groupsRef.doc(groupId).update({
            'members': FieldValue.arrayRemove([username])
          }),
          usersRef.doc(uid).update({
            'groups': FieldValue.arrayRemove([
              {'groupId': groupId}
            ])
          }),
        ]).then((_) {
          return groupsRef.doc(groupId).get().then((groupDoc) {
            if (groupDoc['members'].isEmpty) {
              return groupsRef.doc(groupId).delete();
            } else if (groupDoc['admin'] == username) {
              return groupsRef
                  .doc(groupId)
                  .update({'admin': groupDoc['members'][0]});
            }
          });
        });
      } else {
        return Future.wait([
          groupsRef.doc(groupId).update({
            'members': FieldValue.arrayUnion([username])
          }),
          usersRef.doc(uid).update({
            'groups': FieldValue.arrayUnion([
              {'groupId': groupId}
            ])
          }),
        ]);
      }
    });
  }

  static void sendMessage(String groupId, Message message) {
    Map<String, dynamic> messageMap = message.toMap();

    groupsRef.doc(groupId).collection('messages').add(messageMap);
    groupsRef.doc(groupId).update({
      'recentMessage': message.content,
      'recentMessageSender': message.sender,
      'recentMessageTime': message.time,
    });
  }

  static Stream<List<DocumentSnapshot<Map<String, dynamic>>>> getGroupsStream(
      String username) {
    // Create a reference to the 'groups' collection

    // Query groups where the user is a member
    final query = groupsRef.where('members', arrayContains: username);
    // Return a stream of snapshots of the documents in the query result
    return query.snapshots().map((snapshot) =>
        snapshot.docs.cast<DocumentSnapshot<Map<String, dynamic>>>());
  }

  static Future<bool> isUsernameTaken(String username) async {
    final QuerySnapshot result =
        await usersRef.where('username', isEqualTo: username).get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  static Future<String> getUserImage(String uid) async {
    return await usersRef.doc(uid).get().then((documentSnapshot) {
      return documentSnapshot['imageUrl'];
    });
  }

  static Future<bool> isFollowing(String user, String visitor) async {
    DocumentSnapshot userDoc = await followersRef.doc(user).get();
    List<dynamic> followers = userDoc['followers'];
    return followers.contains(visitor);
  }

  static void toggleFollowUnfollow(String user, String visitor) async {
    debugPrint('Toggling follow/unfollow');

    debugPrint('User: $user');
    debugPrint('Visitor: $visitor');
    DocumentSnapshot userDoc = await followersRef.doc(user).get();
    DocumentSnapshot visitorDoc = await followersRef.doc(visitor).get();

    debugPrint('User document exists');
    // Check if the visitor is already following the user
    List<dynamic> followers = userDoc['followers'];
    List<dynamic> following = visitorDoc['following'];
    if (followers.contains(visitor)) {
      // Visitor is following the user, unfollow
      debugPrint('Visitor is following the user, unfollowing');
      followers.remove(visitor);
      following.remove(user);
      followersRef.doc(user).update({'followers': followers});
      followersRef.doc(visitor).update({'following': following});
    } else {
      // Visitor is not following the user, follow
      debugPrint('Visitor is not following the user, following');
      followers.add(visitor);
      following.add(user);
      followersRef.doc(user).update({'followers': followers});
      followersRef.doc(visitor).update({'following': following});
    }
  }

  static Stream<List<DocumentSnapshot<Map<String, dynamic>>>>
      getFollowersStream(String username) {
    return followersRef.doc(username).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final List<DocumentSnapshot<Map<String, dynamic>>> snapshots = [];
        snapshots.add(snapshot);
        return snapshots;
      } else {
        return [];
      }
    });
  }
}
