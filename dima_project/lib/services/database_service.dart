import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:flutter/cupertino.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static Future<void> registerUserWithUUID(UserData user, String uuid) async {
    String imageUrl = await StorageService.uploadImageToStorage(
        'profile_images/$uuid.jpg', user.imagePath as Uint8List);

    List<Map<String, dynamic>> serializedList =
        user.categories.map((item) => {'value': item}).toList();
    await _firestore.collection('users').doc(uuid).set({
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
    DocumentSnapshot documentSnapshot =
        await _firestore.collection('users').doc(uid).get();
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
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
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
    await _firestore.collection('users').doc(uuid).update({
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
    final QuerySnapshot result = await _firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
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
        await FirebaseFirestore.instance.collection('users').doc(uid).get();

    List<Map<String, dynamic>> groups =
        List<Map<String, dynamic>>.from(groupsSnapshot['groups']);
    debugPrint(groups.toString());

    List<DocumentSnapshot<Map<String, dynamic>>> result = [];
    if (groups.isNotEmpty) {
      for (Map<String, dynamic> groupId in groups) {
        DocumentSnapshot<Map<String, dynamic>> groupDoc =
            await FirebaseFirestore.instance
                .collection('groups')
                .doc(groupId["groupId"])
                .get();
        result.add(groupDoc);
      }
    }
    debugPrint(result.toString());
    return result;
  }

  //create a group
  static Future<void> createGroup(String groupName, String uid) async {
    DocumentReference docRef = await _firestore.collection('groups').add({
      'groupName': groupName,
      'groupIcon': "",
      'admin': uid,
      'messages': [],
      'groupId': "",
      'recentMessage': "",
      'recentMessageSender': "",
    });

    await _firestore.collection('groups').doc(docRef.id).update({
      "members": FieldValue.arrayUnion([uid]),
      'groupId': docRef.id,
    });
    DocumentReference userDocumentReference =
        _firestore.collection('users').doc(uid);

    return await userDocumentReference.update({
      'groups': FieldValue.arrayUnion([
        {
          'groupId': docRef.id,
        }
      ])
    });
  }

  static getChats(String groupId) async {
    return _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .orderBy('time')
        .snapshots();
  }

  static Future getGroupAdmin(String groupId) async {
    DocumentSnapshot<Map<String, dynamic>> groupDoc =
        await _firestore.collection('groups').doc(groupId).get();
    return groupDoc['admin'];
  }

  static Future getGroupMembers(String groupId) async {
    return _firestore.collection('groups').doc(groupId).snapshots();
  }

  static searchByName(String groupName) async {
    return _firestore
        .collection('groups')
        .where('groupName', isEqualTo: groupName)
        .get();
  }

  static Future<bool> isUserJoined(String groupId, String uid) async {
    DocumentSnapshot<Map<String, dynamic>> groupDoc =
        await _firestore.collection('groups').doc(groupId).get();
    List<dynamic> members = groupDoc['members'];
    return members.contains(uid);
  }

  static Future toggleGroupJoin(String groupId, String uid) {
    return isUserJoined(groupId, uid).then((value) {
      if (value) {
        return _firestore.collection('groups').doc(groupId).update({
          'members': FieldValue.arrayRemove([uid])
        }).then((value) {
          return _firestore.collection('users').doc(uid).update({
            'groups': FieldValue.arrayRemove([
              {
                'groupId': groupId,
              }
            ])
          });
        });
      } else {
        return _firestore.collection('groups').doc(groupId).update({
          'members': FieldValue.arrayUnion([uid])
        }).then((value) {
          return _firestore.collection('users').doc(uid).update({
            'groups': FieldValue.arrayUnion([
              {
                'groupId': groupId,
              }
            ])
          });
        });
      }
    });
  }

  static void sendMessage(
      String groupId, Map<String, dynamic> chatMessageData) {
    _firestore
        .collection('groups')
        .doc(groupId)
        .collection('messages')
        .add(chatMessageData);
    _firestore.collection('groups').doc(groupId).update({
      'recentMessage': chatMessageData['message'],
      'recentMessageSender': chatMessageData['sender'],
      'recentMessageTime': chatMessageData['time'].toString(),
    });
  }
}
