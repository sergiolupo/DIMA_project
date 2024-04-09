import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:flutter/cupertino.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final groupRef = _firestore.collection('groups');
  static final userRef = _firestore.collection('users');

  static Future<void> registerUserWithUUID(UserData user, String uuid) async {
    String imageUrl = await StorageService.uploadImageToStorage(
        'profile_images/$uuid.jpg', user.imagePath as Uint8List);

    List<Map<String, dynamic>> serializedList =
        user.categories.map((item) => {'value': item}).toList();
    await userRef.doc(uuid).set({
      'name': user.name,
      'surname': user.surname,
      'username': user.username,
      'email': user.email,
      'imageUrl': imageUrl,
      'selectedCategories': serializedList,
      'groups': [],
    });
  }

  static Future<UserData> getUserData(String uid) async {
    DocumentSnapshot documentSnapshot = await userRef.doc(uid).get();
    UserData user = UserData(
        name: documentSnapshot['name'],
        surname: documentSnapshot['surname'],
        username: documentSnapshot['username'],
        email: documentSnapshot['email'],
        password: '',
        imagePath: await StorageService.downloadImageFromStorage(
            documentSnapshot['imageUrl']),
        categories: documentSnapshot['selectedCategories']
            .map((categoryMap) => categoryMap['value'].toString())
            .toList()
            .cast<String>());
    return user;
  }

  Future<String> findUUID(String email) async {
    final QuerySnapshot result =
        await userRef.where('email', isEqualTo: email).get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      return documents[0].id;
    } else {
      return '';
    }
  }

  Future<void> updateUserData(UserData user) async {
    String uuid = await findUUID(user.email);
    String imageUrl = await StorageService.uploadImageToStorage(
        'profile_images/$uuid.jpg', user.imagePath!);

    List<Map<String, dynamic>> serializedList =
        user.categories.map((item) => {'value': item}).toList();
    await userRef.doc(uuid).update({
      'name': user.name,
      'surname': user.surname,
      'username': user.username,
      'email': user.email,
      'imageUrl': imageUrl,
      'selectedCategories': serializedList,
      'groups': [],
    });
  }

  static Future<bool> checkUserExist(String email) async {
    debugPrint('Checking if user exists... $email');
    final QuerySnapshot result =
        await userRef.where('email', isEqualTo: email).get();
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
        await userRef.doc(uid).get();

    List<Map<String, dynamic>> groups =
        List<Map<String, dynamic>>.from(groupsSnapshot['groups']);

    List<DocumentSnapshot<Map<String, dynamic>>> result = [];
    if (groups.isNotEmpty) {
      for (Map<String, dynamic> groupId in groups) {
        DocumentSnapshot<Map<String, dynamic>> groupDoc =
            await groupRef.doc(groupId["groupId"]).get();
        result.add(groupDoc);
      }
    }
    return result;
  }

  //create a group
  static Future<void> createGroup(
    Group group,
    String uid,
  ) async {
    try {
      String imageUrl = group.imagePath.toString() == '[]'
          ? ''
          : await StorageService.uploadImageToStorage(
              'group_images/$uid.jpg', group.imagePath as Uint8List);

      DocumentReference docRef = await groupRef.add({
        'groupName': group.name,
        'groupImage': imageUrl,
        'admin': group.admin,
        'description': group.description,
        'messages': [],
        'groupId': '',
        'recentMessage': "",
        'recentMessageSender': "",
        "members": FieldValue.arrayUnion([group.admin]),
      });

      await groupRef.doc(docRef.id).update({
        'groupId': docRef.id,
      });
      DocumentReference userDocumentReference = userRef.doc(uid);

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
    return groupRef
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  static Future getGroupAdmin(String groupId) async {
    DocumentSnapshot<Map<String, dynamic>> groupDoc =
        await groupRef.doc(groupId).get();
    return groupDoc['admin'];
  }

  static Future getGroupMembers(String groupId) async {
    return groupRef.doc(groupId).snapshots();
  }

  static searchByGroupNameStream(String searchText) {
    return groupRef
        .where('groupName', isEqualTo: searchText)
        .where('groupId', isNotEqualTo: '')
        .snapshots();
  }

  static searchByUsernameStream(String searchText) {
    return userRef.where('username', isEqualTo: searchText).snapshots();
  }

  static isUserJoined(String groupId, String username) async {
    DocumentSnapshot<Map<String, dynamic>> groupDoc =
        await groupRef.doc(groupId).get();

    List<dynamic> members = groupDoc['members'];
    return members.contains(username);
  }

  static Future toggleGroupJoin(String groupId, String uid, String username) {
    return isUserJoined(groupId, username).then((isJoined) {
      if (isJoined) {
        return Future.wait([
          groupRef.doc(groupId).update({
            'members': FieldValue.arrayRemove([username])
          }),
          userRef.doc(uid).update({
            'groups': FieldValue.arrayRemove([
              {'groupId': groupId}
            ])
          }),
        ]).then((_) {
          return groupRef.doc(groupId).get().then((groupDoc) {
            if (groupDoc['members'].isEmpty) {
              return groupRef.doc(groupId).delete();
            } else if (groupDoc['admin'] == username) {
              return groupRef
                  .doc(groupId)
                  .update({'admin': groupDoc['members'][0]});
            }
          });
        });
      } else {
        return Future.wait([
          groupRef.doc(groupId).update({
            'members': FieldValue.arrayUnion([username])
          }),
          userRef.doc(uid).update({
            'groups': FieldValue.arrayUnion([
              {'groupId': groupId}
            ])
          }),
        ]);
      }
    });
  }

  static void sendMessage(
      String groupId, Map<String, dynamic> chatMessageData) {
    groupRef.doc(groupId).collection('messages').add(chatMessageData);
    groupRef.doc(groupId).update({
      'recentMessage': chatMessageData['message'],
      'recentMessageSender': chatMessageData['sender'],
      'recentMessageTime': chatMessageData['time'].toString(),
    });
  }

  static Stream<List<DocumentSnapshot<Map<String, dynamic>>>> getGroupsStream(
      String username) {
    // Create a reference to the 'groups' collection
    final CollectionReference groupsRef =
        FirebaseFirestore.instance.collection('groups');

    // Query groups where the user is a member
    final query = groupsRef.where('members', arrayContains: username);
    // Return a stream of snapshots of the documents in the query result
    return query.snapshots().map((snapshot) =>
        snapshot.docs.cast<DocumentSnapshot<Map<String, dynamic>>>());
  }

  static Future<bool> isUsernameTaken(String username) async {
    final QuerySnapshot result =
        await userRef.where('username', isEqualTo: username).get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }
}
