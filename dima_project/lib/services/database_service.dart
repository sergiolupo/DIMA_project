import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/event.dart';

class DatabaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final groupsRef = _firestore.collection('groups');
  static final usersRef = _firestore.collection('users');
  static final followersRef = _firestore.collection('followers');
  static final privateChatRef = _firestore.collection('private_chats');
  static final eventsRef = _firestore.collection('events');

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
      'isOnline': false,
      'lastSeen': Timestamp.now(),
      'isTyping': false,
      'typingTo': '',
      'isPublic': true,
      'events': [],
      'eventsRequests': [],
    });

    await followersRef.doc(uuid).set({
      'followers': [],
      'following': [],
      'requests': [],
    });
  }

  static Future<void> updateUserInformation(UserData user, Uint8List imagePath,
      bool imageHasChanged, bool visibilityHasChange) async {
    if (imageHasChanged) {
      String imageUrl = imagePath.toString() == '[]' || imagePath.isEmpty
          ? ''
          : await StorageService.uploadImageToStorage(
              'profile_images/${user.uuid!}.jpg', imagePath);
      List<Map<String, dynamic>> serializedList =
          user.categories.map((item) => {'value': item}).toList();

      await usersRef.doc(user.uuid).update({
        'name': user.name,
        'surname': user.surname,
        'username': user.username,
        'email': user.email,
        'imageUrl': imageUrl,
        'selectedCategories': serializedList,
        'isPublic': user.isPublic,
      });
    } else {
      List<Map<String, dynamic>> serializedList =
          user.categories.map((item) => {'value': item}).toList();
      await usersRef.doc(user.uuid).update({
        'name': user.name,
        'surname': user.surname,
        'username': user.username,
        'email': user.email,
        'selectedCategories': serializedList,
        'isPublic': user.isPublic,
      });
    }
    if (visibilityHasChange && user.isPublic!) {
      DocumentSnapshot<Map<String, dynamic>> userDoc =
          await followersRef.doc(user.uuid).get();
      List<dynamic> followers = userDoc['followers'];
      List<dynamic> requests = userDoc['requests'];
      followers.addAll(requests);
      await followersRef.doc(user.uuid).update({
        'followers': followers,
        'requests': [],
      });
    }
  }

  static Stream<List<String>> getCategories(String uuid) {
    return usersRef.doc(uuid).snapshots().map((snapshot) {
      return UserData.fromSnapshot(snapshot).categories;
    });
  }

  static Future<UserData> getUserData(String uid) async {
    DocumentSnapshot documentSnapshot = await usersRef.doc(uid).get();
    UserData user = UserData.fromSnapshot(documentSnapshot);
    return user;
  }

  static Stream<UserData> getUserDataFromUUID(String uuid) {
    return usersRef.doc(uuid).snapshots().map((snapshot) {
      return UserData.fromSnapshot(snapshot);
    });
  }

  static Stream<Event> getEventFromId(String id) {
    return eventsRef.doc(id).snapshots().map((snapshot) {
      return Event.fromSnapshot(snapshot);
    });
  }

  static Future<UserData> getUserDataFromUsername(String username) async {
    username = username.replaceAll('[', '').replaceAll(']', '');

    QuerySnapshot querySnapshot =
        await usersRef.where('username', isEqualTo: username).get();
    DocumentSnapshot documentSnapshot = querySnapshot.docs.first;
    UserData user = UserData.fromSnapshot(documentSnapshot);
    return user;
  }

  static Future<String> findUUID(String email) async {
    final QuerySnapshot result =
        await usersRef.where('email', isEqualTo: email).get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      return documents[0].id;
    } else {
      return '';
    }
  }

  static Future<String> getUUIDFromUsername(String username) async {
    final QuerySnapshot result =
        await usersRef.where('username', isEqualTo: username).get();
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
        'isPublic': group.isPublic,
        'requests': [],
        'notify': group.notify,
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

  static Stream<List<Message>> getChats(String groupId) async* {
    final chats = await groupsRef
        .doc(groupId)
        .collection('messages')
        .orderBy('time', descending: true)
        .get();

    final chatList = <Message>[];
    for (var chat in chats.docs) {
      chatList.add(Message.fromSnapshot(
          chat, groupId, FirebaseAuth.instance.currentUser!.uid));
    }
    yield chatList; // yield the initial list of messages
    final snapshots = groupsRef
        .doc(groupId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots(); // listen to changes in the groups collection

    await for (var snapshot in snapshots) {
      for (var change in snapshot.docChanges) {
        final chat = Message.fromSnapshot(
            change.doc, groupId, FirebaseAuth.instance.currentUser!.uid);
        if (change.type == DocumentChangeType.removed) {
          chatList.removeWhere((c) => c.id == chat.id);
          yield chatList;
        } else {
          final existingChatIndex = chatList.indexWhere((c) => c.id == chat.id);
          if (existingChatIndex != -1) {
            chatList[existingChatIndex] = chat;
          } else {
            //add to the list if it doesn't exist
            chatList.insert(0, chat);
          }
          yield chatList;
        }
      }
    }
  }

  static Future getGroupAdmin(String groupId) async {
    DocumentSnapshot<Map<String, dynamic>> groupDoc =
        await groupsRef.doc(groupId).get();
    return groupDoc['admin'];
  }

  static Stream<List<dynamic>> getGroupMembers(String groupId) {
    return groupsRef.doc(groupId).snapshots().map((snapshot) {
      return snapshot['members'];
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

  static Future<void> toggleGroupJoin(String groupId, String uuid) async {
    DocumentSnapshot<Map<String, dynamic>> groupDoc =
        await groupsRef.doc(groupId).get();
    bool isJoined = groupDoc['members'].contains(uuid);

    if (isJoined) {
      await Future.wait([
        groupsRef.doc(groupId).update({
          'members': FieldValue.arrayRemove([uuid])
        }),
        usersRef.doc(uuid).update({
          'groups': FieldValue.arrayRemove([groupId])
        }),
      ]);

      DocumentSnapshot<Map<String, dynamic>> groupDoc =
          await groupsRef.doc(groupId).get();
      if (groupDoc['members'].isEmpty) {
        await groupsRef.doc(groupId).delete();
      } else if (groupDoc['admin'] == uuid) {
        await groupsRef.doc(groupId).update({'admin': groupDoc['members'][0]});
      }
    } else {
      if (groupDoc['isPublic']) {
        await Future.wait([
          groupsRef.doc(groupId).update({
            'members': FieldValue.arrayUnion([uuid])
          }),
          usersRef.doc(uuid).update({
            'groups': FieldValue.arrayUnion([groupId])
          }),
        ]);
      } else {
        if (!groupDoc['requests'].contains(uuid)) {
          await groupsRef.doc(groupId).update({
            'requests': FieldValue.arrayUnion([uuid])
          });
        } else {
          await groupsRef.doc(groupId).update({
            'requests': FieldValue.arrayRemove([uuid])
          });
        }
      }
    }
  }

  static void sendMessage(String? id, Message message) async {
    Map<String, dynamic> messageMap = message.toMap();

    if (message.isGroupMessage) {
      groupsRef.doc(id).collection('messages').add(messageMap);
      groupsRef.doc(id).update({
        'recentMessage': message.type == Type.text ? message.content : 'Image',
        'recentMessageSender': message.sender,
        'recentMessageTime': message.time,
      });
    } else {
      privateChatRef.doc(id).collection('messages').add(messageMap);
      privateChatRef.doc(id).update({
        'recentMessage': message.type == Type.text ? message.content : 'Image',
        'recentMessageSender': message.sender,
        'recentMessageTime': message.time,
      });
    }
  }

  static Future<PrivateChat> getPrivateChatsFromMember(
      List<String> members) async {
    QuerySnapshot<Object?> value =
        await privateChatRef.where("members", isEqualTo: members).get();
    if (value.docs.isEmpty) {
      return PrivateChat(members: members);
    }
    return PrivateChat.fromSnapshot(
        await privateChatRef.doc(value.docs.first.id).get());
  }

  static Future sendFirstPrivateMessage(Message message, String id) async {
    Map<String, dynamic> messageMap = message.toMap();
    return await privateChatRef.doc(id).collection('messages').add(messageMap);
  }

  static Future<String> createPrivateChat(PrivateChat privateChat) async {
    List<String> members = privateChat.members;
    members.sort();
    return await privateChatRef.add({
      'members': members,
      'recentMessage': "",
      'recentMessageSender': "",
      'recentMessageTime': "",
    }).then((value) async {
      final id = value.id;
      await usersRef.doc(members[0]).update({
        'privateChats': FieldValue.arrayUnion([id])
      });
      await usersRef.doc(members[1]).update({
        'privateChats': FieldValue.arrayUnion([id])
      });
      return id;
    });
  }

  static Stream<List<Group>> getGroupsStream(String uuid) async* {
    final groupIds = await usersRef.doc(uuid).get().then((value) {
      return value['groups'];
    });

    final groupsList = <Group>[];
    for (var groupId in groupIds) {
      final snapshot = await groupsRef.doc(groupId).get();
      if (snapshot.exists) {
        groupsList.add(Group.fromSnapshot(snapshot));
      }
    }
    yield groupsList; // yield the initial list of groups
    final snapshots =
        groupsRef.snapshots(); // listen to changes in the groups collection

    await for (var snapshot in snapshots) {
      for (var change in snapshot.docChanges) {
        final groupId = change.doc.id;
        final group = Group.fromSnapshot(change.doc);
        final members = group.members;

        if (change.type == DocumentChangeType.removed) {
          groupsList.removeWhere((g) => g.id == groupId);
          yield groupsList;
        } else {
          if (members!.contains(uuid) && group.id != '') {
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

  static Stream<List<PrivateChat>> getPrivateChatsStream() async* {
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
        chatsList.add(PrivateChat.fromSnapshot(snapshot));
      }
    }
    yield chatsList; // yield the initial list of private chats

    final snapshots = privateChatRef
        .snapshots(); // listen to changes in the groups collection

    await for (var snapshot in snapshots) {
      for (var change in snapshot.docChanges) {
        final id = change.doc.id;
        if (!change.doc
            .data()!['members']
            .contains(FirebaseAuth.instance.currentUser!.uid)) {
          continue;
        }
        final privateChat = PrivateChat.fromSnapshot(change.doc);
        if (change.type == DocumentChangeType.removed) {
          chatsList.removeWhere((g) => g.id == id);
          yield chatsList;
        } else {
          if (privateChat.members
              .contains(FirebaseAuth.instance.currentUser!.uid)) {
            // DocumentChangeType.added or DocumentChangeType.modified
            final existingGroupIndex = chatsList.indexWhere((g) => g.id == id);
            if (existingGroupIndex != -1) {
              chatsList[existingGroupIndex] = privateChat;
            } else {
              chatsList.add(privateChat);
            }
            yield chatsList;
          }
        }
        yield chatsList;
      }
    }
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getFollowersStreamUser(
      String uuid) {
    final stream = followersRef.doc(uuid).snapshots();

    return stream.map((snapshot) {
      return snapshot;
    });
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getMembersStreamUser(
      String eventId) {
    final stream = eventsRef.doc(eventId).snapshots();

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

  static Stream<bool> isFollowingUser(String user, String visitor) async* {
    DocumentSnapshot userDoc = await followersRef.doc(user).get();
    yield userDoc['followers'].contains(visitor);

    final snapshots = followersRef.doc(user).snapshots();
    await for (var snapshot in snapshots) {
      yield snapshot['followers'].contains(visitor);
    }
  }

  static Stream<int> isFollowing(String user, String visitor) async* {
    // 0 is not following, 1 is following, 2 is requested

    // Initial check
    DocumentSnapshot followDoc = await followersRef.doc(user).get();
    DocumentSnapshot userDoc = await usersRef.doc(user).get();

    yield _getFollowStatus(followDoc, userDoc, visitor);

    // Listen for real-time updates
    await for (var snapshot in followersRef.doc(user).snapshots()) {
      followDoc = snapshot;
      userDoc = await usersRef.doc(user).get();

      yield _getFollowStatus(followDoc, userDoc, visitor);
    }
  }

  // Helper method to determine follow status
  static int _getFollowStatus(
      DocumentSnapshot followDoc, DocumentSnapshot userDoc, String visitor) {
    if (followDoc['followers'].contains(visitor)) {
      return 1;
    } else if (userDoc['isPublic'] == false &&
        followDoc['requests'].contains(visitor)) {
      return 2;
    } else {
      return 0;
    }
  }

  static Stream<int> isJoining(String uuid, String eventId) async* {
    // 0 is not joining, 1 is joining, 2 is requested

    // Initial check
    DocumentSnapshot eventDoc = await eventsRef.doc(eventId).get();
    DocumentSnapshot userDoc = await usersRef.doc(uuid).get();

    yield _getEventStatus(eventDoc, userDoc, uuid);

    // Listen for real-time updates
    await for (var snapshot in eventsRef.doc(eventId).snapshots()) {
      eventDoc = snapshot;
      userDoc = await usersRef.doc(uuid).get();

      yield _getEventStatus(eventDoc, userDoc, uuid);
    }
  }

  // Helper method to determine follow status
  static int _getEventStatus(
    DocumentSnapshot eventDoc,
    DocumentSnapshot userDoc,
    String uuid,
  ) {
    if (eventDoc['members'].contains(uuid)) {
      return 1;
    } else if (userDoc['isPublic'] == false &&
        eventDoc['requests'].contains(uuid)) {
      return 2;
    } else {
      return 0;
    }
  }

  static Future<void> toggleFollowUnfollow(String user, String visitor) async {
    debugPrint('Toggling follow/unfollow');

    debugPrint('User: $user');
    debugPrint('Visitor: $visitor');
    DocumentSnapshot userDoc = await followersRef.doc(user).get();
    DocumentSnapshot visitorDoc = await followersRef.doc(visitor).get();

    DocumentSnapshot doc = await usersRef.doc(user).get();

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
      debugPrint(doc['isPublic'].toString());
      if (doc['isPublic'] == false) {
        if (userDoc['requests'].contains(visitor)) {
          followersRef.doc(user).update({
            'requests': FieldValue.arrayRemove([visitor])
          });
        } else {
          followersRef.doc(user).update({
            'requests': FieldValue.arrayUnion([visitor])
          });
        }
        return;
      }

      // Visitor is not following the user, follow
      debugPrint('Visitor is not following the user, following');
      followers.add(visitor);
      following.add(user);
      await followersRef.doc(user).update({'followers': followers});
      await followersRef.doc(visitor).update({'following': following});
    }
  }

// Assuming privateChatRef is your reference to the private chat collection

  static Stream<List<Message>> getPrivateChats(List<String> members) async* {
    // Sort members to maintain a consistent order
    members.sort();

    // Helper function to fetch and yield initial chat messages
    Future<List<Message>> fetchInitialMessages(String chatId) async {
      final chats = await privateChatRef
          .doc(chatId)
          .collection('messages')
          .orderBy('time', descending: true)
          .get();

      return chats.docs.map<Message>((doc) {
        return Message.fromSnapshot(
            doc, chatId, FirebaseAuth.instance.currentUser!.uid);
      }).toList();
    }

    // Helper function to listen for real-time updates
    Stream<List<Message>> listenToChatUpdates(String chatId) async* {
      final snapshots = privateChatRef
          .doc(chatId)
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots();

      var chatList = await fetchInitialMessages(chatId);
      yield chatList; // Yield the initial list of messages

      await for (var snapshot in snapshots) {
        for (var change in snapshot.docChanges) {
          final chat = Message.fromSnapshot(
              change.doc, chatId, FirebaseAuth.instance.currentUser!.uid);

          if (change.type == DocumentChangeType.removed) {
            chatList.removeWhere((c) => c.id == chat.id);
          } else {
            final existingChatIndex =
                chatList.indexWhere((c) => c.id == chat.id);
            if (existingChatIndex != -1) {
              chatList[existingChatIndex] = chat;
            } else {
              chatList.insert(0, chat);
            }
          }
          yield chatList;
        }
      }
    }

    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await privateChatRef.where("members", isEqualTo: members).get();

    if (querySnapshot.docs.isNotEmpty) {
      final privateChatId = querySnapshot.docs.first.id;
      yield* listenToChatUpdates(privateChatId);
    } else {
      yield <Message>[];

      await for (var snapshot in privateChatRef.snapshots()) {
        for (var change in snapshot.docChanges) {
          if (change.type == DocumentChangeType.added) {
            final privateChat = PrivateChat.fromSnapshot(change.doc);
            if (privateChat.members.contains(members[0]) &&
                privateChat.members.contains(members[1])) {
              final privateChatId = change.doc.id;
              yield* listenToChatUpdates(privateChatId);
            }
          }
        }
      }
    }
  }

  static Stream<int> getUnreadMessages(bool isGroup, String id, String uuid) {
    if (!isGroup) {
      return privateChatRef
          .doc(id)
          .collection('messages')
          .snapshots()
          .map((snapshot) {
        int unreadCount = 0;
        for (var doc in snapshot.docs) {
          var readBy = doc.data()['readBy'] ?? {};
          // Check if the message hasn't been read by the user
          var read = false;
          for (var value in readBy) {
            if ((uuid == value['username'])) {
              read = true;
              break;
            }
          }
          if (!read) {
            unreadCount++;
          }
        }
        return unreadCount;
      });
    } else {
      return groupsRef
          .doc(id)
          .collection('messages')
          .snapshots()
          .map((snapshot) {
        int unreadCount = 0;
        for (var doc in snapshot.docs) {
          var readBy = doc.data()['readBy'] ?? {};
          // Check if the message hasn't been read by the user
          var read = false;
          for (var value in readBy) {
            if ((uuid == value['username'])) {
              read = true;
              break;
            }
          }
          if (!read) {
            unreadCount++;
          }
        }
        return unreadCount;
      });
    }
  }

  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      getGroupsStreamUser(String uuid) {
    // Fetch all documents from Firestore collection
    final query = groupsRef.where('members', arrayContains: uuid).snapshots();
    return query.map((snapshot) {
      return snapshot.docs;
    });
  }

  static Future<void> updateMessageReadStatus(
      String uuid, Message message) async {
    ReadBy readBy = ReadBy(readAt: Timestamp.now(), username: uuid);

    if (message.isGroupMessage) {
      await groupsRef
          .doc(message.chatID)
          .collection('messages')
          .doc(message.id)
          .update({
        'readBy': FieldValue.arrayUnion([
          readBy.toMap(),
        ])
      });
    } else {
      await privateChatRef
          .doc(message.chatID)
          .collection('messages')
          .doc(message.id)
          .update({
        'readBy': FieldValue.arrayUnion([readBy.toMap()])
      });
    }
  }

  static void deleteMessage(Message message) async {
    if (message.isGroupMessage) {
      await groupsRef
          .doc(message.chatID)
          .collection('messages')
          .doc(message.id)
          .delete();

      final recentMessage = (await groupsRef.doc(message.chatID).get());
      if (recentMessage['recentMessage'] == message.content &&
          recentMessage['recentMessageSender'] == message.sender &&
          recentMessage['recentMessageTime'] == message.time) {
        var messagesSnapshot = await groupsRef
            .doc(message.chatID)
            .collection('messages')
            .orderBy('time', descending: false)
            .get();
        if (messagesSnapshot.docs.isNotEmpty) {
          await groupsRef.doc(message.chatID).update({
            'recentMessage': messagesSnapshot.docs.last['content'],
            'recentMessageSender': messagesSnapshot.docs.last['sender'],
            'recentMessageTime': messagesSnapshot.docs.last['time'],
          });
        } else {
          await groupsRef.doc(message.chatID).update({
            'recentMessage': '',
            'recentMessageSender': '',
            'recentMessageTime': '',
          });
        }
      }
    } else {
      await privateChatRef
          .doc(message.chatID)
          .collection('messages')
          .doc(message.id)
          .delete();
      final recentMessage = (await privateChatRef.doc(message.chatID).get());
      if (recentMessage['recentMessage'] == message.content &&
          recentMessage['recentMessageSender'] == message.sender &&
          recentMessage['recentMessageTime'] == message.time) {
        var messagesSnapshot = await privateChatRef
            .doc(message.chatID)
            .collection('messages')
            .orderBy('time', descending: false)
            .get();
        if (messagesSnapshot.docs.isNotEmpty) {
          await privateChatRef.doc(message.chatID).update({
            'recentMessage': messagesSnapshot.docs.last['content'],
            'recentMessageSender': messagesSnapshot.docs.last['sender'],
            'recentMessageTime': messagesSnapshot.docs.last['time'],
          });
        } else {
          /*await privateChatRef.doc(message.chatID).delete();
          await usersRef.doc(FirebaseAuth.instance.currentUser!.uid).update({
            'privateChats': FieldValue.arrayRemove([message.chatID])
          });
          await usersRef.doc(message.receiver).update({
            'privateChats': FieldValue.arrayRemove([message.chatID])
          });
          return true;*/
          await privateChatRef.doc(message.chatID).update({
            'recentMessage': '',
            'recentMessageSender': '',
            'recentMessageTime': '',
          });
        }
      }
    }
  }

  static void updateMessageContent(Message message, String updatedMessage) {
    Timestamp time = Timestamp.now();
    if (message.isGroupMessage) {
      groupsRef
          .doc(message.chatID)
          .collection('messages')
          .doc(message.id)
          .update({'content': updatedMessage, 'time': time, 'readBy': []});
      groupsRef.doc(message.chatID).update({
        'recentMessage': updatedMessage,
        'recentMessageSender': message.sender,
        'recentMessageTime': time,
      });
    } else {
      privateChatRef
          .doc(message.chatID)
          .collection('messages')
          .doc(message.id)
          .update({'content': updatedMessage, 'time': time, 'readBy': []});
      privateChatRef.doc(message.chatID).update({
        'recentMessage': updatedMessage,
        'recentMessageSender': message.sender,
        'recentMessageTime': time,
      });
    }
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getUserInfo(
      String uuid) {
    return usersRef.doc(uuid).snapshots();
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    await usersRef.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'isOnline': isOnline,
      'lastSeen': Timestamp.now(),
    });
  }

  static void updateTyping(String s, bool bool) {
    usersRef.doc(FirebaseAuth.instance.currentUser!.uid).update({
      'isTyping': bool,
      'typingTo': s,
    });
  }

  static Future<void> sendChatImage(String uuid, String chatID, File file,
      bool isGroupMessage, Uint8List imagePath) async {
    final String imageUrl = await StorageService.uploadImageToStorage(
        'chat_images/$chatID/$uuid/${Timestamp.now()}.jpg', imagePath);

    ReadBy readBy = ReadBy(
      readAt: Timestamp.now(),
      username: uuid,
    );

    final Message message = Message(
      content: imageUrl,
      sender: uuid,
      isGroupMessage: isGroupMessage,
      time: Timestamp.now(),
      readBy: [
        readBy,
      ],
      type: Type.image,
    );

    sendMessage(chatID, message);
  }

  static Future<bool> isEmailTaken(String email) async {
    final QuerySnapshot result =
        await usersRef.where('email', isEqualTo: email).get();
    final List<DocumentSnapshot> documents = result.docs;
    if (documents.isNotEmpty) {
      return true;
    } else {
      return false;
    }
  }

  static Stream<List<dynamic>> getGroupRequests(String id) {
    return groupsRef.doc(id).snapshots().map((snapshot) {
      return snapshot['requests'];
    });
  }

  static Stream<List<dynamic>> getFollowRequests(String id) {
    return followersRef.doc(id).snapshots().map((snapshot) {
      return snapshot['requests'];
    });
  }

  static Future<void> denyGroupRequest(String groupId, String uuid) async {
    return await groupsRef.doc(groupId).update({
      'requests': FieldValue.arrayRemove([uuid])
    });
  }

  static Future<void> acceptGroupRequest(String groupId, String uuid) async {
    await Future.wait([
      groupsRef.doc(groupId).update({
        'members': FieldValue.arrayUnion([uuid]),
        'requests': FieldValue.arrayRemove([uuid])
      }),
      usersRef.doc(uuid).update({
        'groups': FieldValue.arrayUnion([groupId])
      }),
    ]);
  }

  static Stream<List<dynamic>> getGroupMedia(String id) {
    return groupsRef
        .doc(id)
        .collection('messages')
        .where("type", isEqualTo: 'Type.image')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs;
    });
  }

  static Stream<List<dynamic>> getPrivateChatMedia(String id) {
    return privateChatRef
        .doc(id)
        .collection('messages')
        .where("type", isEqualTo: 'Type.image')
        .orderBy('time', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs;
    });
  }

  static Future<void> acceptUserRequest(String user, String uuid) async {
    await Future.wait([
      followersRef.doc(uuid).update({
        'followers': FieldValue.arrayUnion([user]),
        'requests': FieldValue.arrayRemove([user])
      }),
      followersRef.doc(user).update({
        'following': FieldValue.arrayUnion([uuid])
      }),
    ]);
  }

  static Future<void> denyUserRequest(String user, String uuid) async {
    await followersRef.doc(uuid).update({
      'requests': FieldValue.arrayRemove([user])
    });
  }

  static Future<void> denyEventRequest(String eventId, String uuid) async {
    await usersRef.doc(uuid).update({
      'eventsRequests': FieldValue.arrayRemove([eventId])
    });
  }

  static Future<void> acceptEventRequest(String eventId, String uuid) async {
    await Future.wait([
      eventsRef.doc(eventId).update({
        'members': FieldValue.arrayUnion([eventId]),
      }),
      usersRef.doc(uuid).update({
        'eventsRequests': FieldValue.arrayRemove([eventId])
      }),
    ]);
  }

  static Future<void> createEvent(
      Event event, String uuid, Uint8List imagePath, List<String> uuids) async {
    try {
      DocumentReference docRef = await eventsRef.add(Event.toMap(event));

      String imageUrl = imagePath.toString() == '[]'
          ? ''
          : await StorageService.uploadImageToStorage(
              'event_images/${docRef.id}.jpg', imagePath);

      await eventsRef.doc(docRef.id).update({
        'imagePath': imageUrl,
        'eventId': docRef.id,
        'createdAt': Timestamp.now(),
      });
      await usersRef.doc(uuid).update({
        'events': FieldValue.arrayUnion([
          docRef.id,
        ])
      });
      for (var id in uuids) {
        await usersRef.doc(id).update({
          'eventsRequests': FieldValue.arrayUnion([
            docRef.id,
          ])
        });
      }
    } catch (e) {
      debugPrint("Error while creating the event: $e");
    }
  }

  static searchByEventNameStream(String searchText) {
    return eventsRef.snapshots().map((snapshot) {
      // Filter documents on the client side using regex and group ID check
      return snapshot.docs.where((doc) {
        // Match the 'groupName' field using a regex pattern
        bool nameMatches =
            RegExp(searchText, caseSensitive: false).hasMatch(doc['name']);
        // Check if the 'groupId' field is not empty
        bool validGroupId = doc['eventId'] != '';
        // Return true if both conditions are met
        return nameMatches && validGroupId;
      }).toList();
    });
  }

  static Future<void> toggleEventJoin(String eventId, String uuid) async {
    DocumentSnapshot<Map<String, dynamic>> eventDoc =
        await eventsRef.doc(eventId).get();

    bool isJoined = eventDoc['members'].contains(uuid);

    if (isJoined) {
      await Future.wait([
        eventsRef.doc(eventId).update({
          'members': FieldValue.arrayRemove([uuid])
        }),
        usersRef.doc(uuid).update({
          'events': FieldValue.arrayRemove([eventId])
        }),
      ]);
      if (eventDoc['members'].isEmpty) {
        //await eventsRef.doc(eventId).delete();
      } else if (eventDoc['admin'] == uuid) {
        await eventsRef.doc(eventId).update({'admin': eventDoc['members'][0]});
      }
    } else {
      if (eventDoc['isPublic']) {
        await Future.wait([
          eventsRef.doc(eventId).update({
            'members': FieldValue.arrayUnion([uuid])
          }),
          usersRef.doc(uuid).update({
            'events': FieldValue.arrayUnion([eventId])
          }),
        ]);
      } else {
        if (!eventDoc['requests'].contains(uuid)) {
          await eventsRef.doc(eventId).update({
            'requests': FieldValue.arrayUnion([uuid])
          });
        } else {
          await eventsRef.doc(eventId).update({
            'requests': FieldValue.arrayRemove([uuid])
          });
        }
      }
    }
  }

  static Stream<Event> getEventStream(String eventId) {
    return eventsRef.doc(eventId).snapshots().map((snapshot) {
      return Event.fromSnapshot(snapshot);
    });
  }

  static Stream<List<Event>> getCreatedEventStream(String uuid) async* {
    final eventsIds = await eventsRef.where('admin', isEqualTo: uuid).get();

    final eventsList = <Event>[];

    for (var eventId in eventsIds.docs) {
      final snapshot = await eventsRef.doc(eventId.id).get();
      if (snapshot.exists) {
        eventsList.add(Event.fromSnapshot(snapshot));
      }
    }
    eventsList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    yield eventsList;
    final snapshots = eventsRef.snapshots();
    await for (var snapshot in snapshots) {
      for (var change in snapshot.docChanges) {
        final event = Event.fromSnapshot(change.doc);
        if (change.type == DocumentChangeType.removed) {
          eventsList.removeWhere((e) => e.id == event.id);
          yield eventsList;
        } else {
          if (event.admin == uuid) {
            final existingEventIndex =
                eventsList.indexWhere((e) => e.id == event.id);
            if (existingEventIndex != -1) {
              eventsList[existingEventIndex] = event;
            } else {
              eventsList.add(event);
              eventsList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
            }
            yield eventsList;
          } else {
            eventsList.removeWhere((e) => e.id == event.id);
            yield eventsList;
          }
        }
      }
    }
  }

  static Stream<List<Event>> getJoinedEventStream(String uuid) async* {
    final eventsIds = await eventsRef
        .where('admin', isNotEqualTo: uuid)
        .where('members', arrayContains: uuid)
        .get();

    final eventsList = <Event>[];

    for (var eventId in eventsIds.docs) {
      final snapshot = await eventsRef.doc(eventId.id).get();
      if (snapshot.exists) {
        eventsList.add(Event.fromSnapshot(snapshot));
      }
    }
    eventsList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
    yield eventsList;

    final snapshots = eventsRef.snapshots();
    await for (var snapshot in snapshots) {
      for (var change in snapshot.docChanges) {
        final event = Event.fromSnapshot(change.doc);
        if (change.type == DocumentChangeType.removed) {
          eventsList.removeWhere((e) => e.id == event.id);
          yield eventsList;
        } else {
          if (event.admin != uuid && event.members.contains(uuid)) {
            final existingEventIndex =
                eventsList.indexWhere((e) => e.id == event.id);
            if (existingEventIndex != -1) {
              eventsList[existingEventIndex] = event;
            } else {
              eventsList.add(event);
              eventsList.sort((a, b) => a.createdAt!.compareTo(b.createdAt!));
            }
            yield eventsList;
          } else {
            eventsList.removeWhere((e) => e.id == event.id);
            yield eventsList;
          }
        }
      }
    }
  }

  static Stream<List<dynamic>> getEventRequests(String uuid) {
    return usersRef.doc(uuid).snapshots().map((snapshot) {
      return snapshot['eventsRequests'];
    });
  }
}
