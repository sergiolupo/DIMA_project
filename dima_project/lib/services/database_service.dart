import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final groupsRef = _firestore.collection('groups');
  static final usersRef = _firestore.collection('users');
  static final followersRef = _firestore.collection('followers');
  static final privateChatRef = _firestore.collection('private_chats');
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
      'privateChats': [],
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
        'groupId': '',
        'recentMessage': "",
        'recentMessageSender': "",
        'recentMessageTime': "",
        'members': FieldValue.arrayUnion([group.admin]),
        'categories': serializedList,
      });

      String imageUrl = imagePath.toString() == '[]'
          ? ''
          : await StorageService.uploadImageToStorage(
              'group_images/${docRef.id}.jpg', imagePath);

      await groupsRef.doc(docRef.id).update({
        'groupId': docRef.id,
        'groupImage': imageUrl,
      });
      return await usersRef.doc(uid).update({
        'groups': FieldValue.arrayUnion([
          docRef.id,
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

  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      searchByGroupNameStream(String searchText) {
    // Fetch all documents from Firestore collection
    return groupsRef.snapshots().map((snapshot) {
      // Filter documents on the client side using regex and group ID check
      return snapshot.docs.where((doc) {
        // Match the 'groupName' field using a regex pattern
        bool nameMatches =
            RegExp(searchText, caseSensitive: false).hasMatch(doc['groupName']);
        // Check if the 'groupId' field is not empty
        bool validGroupId = doc['groupId'] != '';
        // Return true if both conditions are met
        return nameMatches && validGroupId;
      }).toList();
    });
  }

  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      searchByUsernameStream(String searchText) {
    // Fetch all documents from Firestore collection
    return usersRef.snapshots().map((snapshot) {
      // Filter documents on the client side using regex
      return snapshot.docs.where((doc) {
        // Match the 'username' field using a regex pattern
        return RegExp(searchText, caseSensitive: false)
            .hasMatch(doc['username']);
      }).toList();
    });
  }

  static Future<void> toggleGroupJoin(
      String groupId, String uid, String username) async {
    DocumentSnapshot<Map<String, dynamic>> groupDoc =
        await groupsRef.doc(groupId).get();
    bool isJoined = groupDoc['members'].contains(username);

    if (isJoined) {
      await Future.wait([
        groupsRef.doc(groupId).update({
          'members': FieldValue.arrayRemove([username])
        }),
        usersRef.doc(uid).update({
          'groups': FieldValue.arrayRemove([groupId])
        }),
      ]);

      DocumentSnapshot<Map<String, dynamic>> groupDoc =
          await groupsRef.doc(groupId).get();
      if (groupDoc['members'].isEmpty) {
        await groupsRef.doc(groupId).delete();
      } else if (groupDoc['admin'] == username) {
        await groupsRef.doc(groupId).update({'admin': groupDoc['members'][0]});
      }
    } else {
      await Future.wait([
        groupsRef.doc(groupId).update({
          'members': FieldValue.arrayUnion([username])
        }),
        usersRef.doc(uid).update({
          'groups': FieldValue.arrayUnion([groupId])
        }),
      ]);
    }
  }

  static void sendMessage(String? id, Message message) async {
    Map<String, dynamic> messageMap = message.toMap();

    if (id != null) {
      groupsRef.doc(id).collection('messages').add(messageMap);
      groupsRef.doc(id).update({
        'recentMessage': message.content,
        'recentMessageSender': message.sender,
        'recentMessageTime': message.time,
      });
    } else {
      List<dynamic> members = [message.sender, message.receiver];
      members.sort();

      QuerySnapshot<Object?> value =
          await privateChatRef.where("members", isEqualTo: members).get();
      await privateChatRef
          .doc(value.docs.first.id)
          .collection('messages')
          .add(messageMap);
      privateChatRef.doc(value.docs.first.id).update({
        'recentMessage': message.content,
        'recentMessageSender': message.sender,
        'recentMessageTime': message.time,
      });
    }
  }

  static Future sendFirstPrivateMessage(Message message) async {
    Map<String, dynamic> messageMap = message.toMap();

    List<dynamic> members = [message.sender, message.receiver];
    members.sort();

    await privateChatRef.add({
      'members': members,
      'recentMessage': message.content,
      'recentMessageSender': message.sender,
      'recentMessageTime': message.time,
    }).then((value) async {
      final id = value.id;

      usersRef.where('username', isEqualTo: message.sender).get().then((value) {
        usersRef.doc(value.docs.first.id).update({
          'privateChats': FieldValue.arrayUnion([id])
        });
      });
      usersRef
          .where('username', isEqualTo: message.receiver)
          .get()
          .then((value) {
        usersRef.doc(value.docs.first.id).update({
          'privateChats': FieldValue.arrayUnion([id])
        });
      });

      return await privateChatRef
          .doc(value.id)
          .collection('messages')
          .add(messageMap);
    });
  }

  static Stream<List<Group>> getGroupsStream(String username) async* {
    final groupIds = await usersRef
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      return value['groups'];
    });

    final groupsList = <Group>[];
    for (var groupId in groupIds) {
      final snapshot = await groupsRef.doc(groupId).get();
      if (snapshot.exists) {
        groupsList.add(Group.convertToGroup(snapshot));
      }
    }
    yield groupsList; // yield the initial list of groups
    final snapshots =
        groupsRef.snapshots(); // listen to changes in the groups collection

    await for (var snapshot in snapshots) {
      for (var change in snapshot.docChanges) {
        final groupId = change.doc.id;
        final group = Group.convertToGroup(change.doc);
        final members = group.members;

        if (change.type == DocumentChangeType.removed) {
          groupsList.removeWhere((g) => g.id == groupId);
          yield groupsList;
        } else {
          if (members!.contains(username)) {
            // DocumentChangeType.added or DocumentChangeType.modified
            final existingGroupIndex =
                groupsList.indexWhere((g) => g.id == groupId);
            if (existingGroupIndex != -1) {
              groupsList[existingGroupIndex] = group;
            } else {
              groupsList.add(group);
            }
            yield groupsList;
          } else {
            groupsList.removeWhere((g) => g.id == groupId);
            yield groupsList;
          }
        }
      }
    }
  }

  static Stream<List<PrivateChat>> getPrivateChatsStream(
      String username) async* {
    final privateChats = await usersRef
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get()
        .then((value) {
      return value['privateChats'];
    });
    final chatsList = <PrivateChat>[];
    for (var id in privateChats) {
      final snapshot = await privateChatRef.doc(id).get();
      if (snapshot.exists) {
        chatsList.add(PrivateChat.convertToPrivateChat(snapshot, username));
      }
    }
    yield chatsList; // yield the initial list of groups

    final snapshots = privateChatRef
        .snapshots(); // listen to changes in the groups collection

    await for (var snapshot in snapshots) {
      for (var change in snapshot.docChanges) {
        final id = change.doc.id;
        final privateChat =
            PrivateChat.convertToPrivateChat(change.doc, username);

        if (privateChats.contains(id)) {
          if (change.type == DocumentChangeType.removed) {
            chatsList.removeWhere((g) => g.id == id);
          } else {
            // DocumentChangeType.added or DocumentChangeType.modified
            final existingGroupIndex = chatsList.indexWhere((g) => g.id == id);
            if (existingGroupIndex != -1) {
              chatsList[existingGroupIndex] = privateChat;
            } else {
              chatsList.add(privateChat);
            }
          }
          yield chatsList;
        }
      }
    }
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getFollowersStreamUser(
      String username) {
    final stream = followersRef.doc(username).snapshots();

    return stream.map((snapshot) {
      return snapshot;
    });
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

  static isFollowing(String user, String visitor) async* {
    DocumentSnapshot userDoc = await followersRef.doc(user).get();
    yield userDoc['followers'].contains(visitor);
    final snapshot = followersRef.doc(user).snapshots();
    await for (var snapshot in snapshot) {
      yield snapshot['followers'].contains(visitor);
    }
  }

  static Future<void> toggleFollowUnfollow(String user, String visitor) async {
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
      await followersRef.doc(user).update({'followers': followers});
      await followersRef.doc(visitor).update({'following': following});
    } else {
      // Visitor is not following the user, follow
      debugPrint('Visitor is not following the user, following');
      followers.add(visitor);
      following.add(user);
      await followersRef.doc(user).update({'followers': followers});
      await followersRef.doc(visitor).update({'following': following});
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

// Assuming privateChatRef is your reference to the private chat collection

  static Future<Stream<QuerySnapshot>?> getPrivateChats(
      String user, String visitor) async {
    List<dynamic> members = [user, visitor];
    members.sort();
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await privateChatRef.where("members", isEqualTo: members).get();

    if (querySnapshot.docs.firstOrNull == null) {
      return null;
    } else {
      // If a private chat exists, return its message collection
      return querySnapshot.docs.first.reference
          .collection('messages')
          .orderBy('time')
          .snapshots();
    }
  }

  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getGroupsStreamUser(String username) {
    // Fetch all documents from Firestore collection
    final query =
        groupsRef.where('members', arrayContains: username).snapshots();
    return query.map((snapshot) {
      return snapshot.docs;
    });
  }
}
