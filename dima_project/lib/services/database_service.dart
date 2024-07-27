import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
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
      'groupsRequests': [],
      'requests': [],
    });

    await followersRef.doc(uuid).set({
      'followers': [],
      'following': [],
    });
  }

  static Future<void> updateUserInformation(
    UserData user,
    Uint8List imagePath,
    bool imageHasChanged,
    bool visibilityHasChange,
  ) async {
    if (imageHasChanged) {
      String imageUrl = imagePath.toString() == '[]' || imagePath.isEmpty
          ? ''
          : await StorageService.uploadImageToStorage(
              'profile_images/${user.uid!}.jpg', imagePath);
      List<Map<String, dynamic>> serializedList =
          user.categories.map((item) => {'value': item}).toList();

      await usersRef.doc(user.uid).update({
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
      await usersRef.doc(user.uid).update({
        'name': user.name,
        'surname': user.surname,
        'username': user.username,
        'email': user.email,
        'selectedCategories': serializedList,
        'isPublic': user.isPublic,
      });
    }
    if (visibilityHasChange && user.isPublic!) {
      List<dynamic> requests = (await usersRef.doc(user.uid).get())['requests'];
      if (requests.isNotEmpty) {
        for (var request in requests) {
          await toggleFollowUnfollow(user.uid!, request);
        }
        await usersRef.doc(user.uid).update({
          'requests': [],
        });
      }
    }
  }

  static Future<UserData> getUserData(String uid) async {
    try {
      DocumentSnapshot documentSnapshot = await usersRef.doc(uid).get();
      UserData user = UserData.fromSnapshot(documentSnapshot);
      return user;
    } catch (e) {
      return UserData(
          categories: [],
          email: '',
          name: '',
          surname: '',
          username: 'Deleted Account',
          imagePath: '');
    }
  }

  static Stream<UserData> getUserDataFromUID(String uid) {
    return usersRef.doc(uid).snapshots().map((snapshot) {
      return UserData.fromSnapshot(snapshot);
    });
  }

  static Stream<Group> getGroupFromIdStream(String id) {
    return groupsRef.doc(id).snapshots().map((snapshot) {
      return Group.fromSnapshot(snapshot);
    });
  }

  static Future<Group> getGroupFromId(String id) {
    return groupsRef.doc(id).get().then((snapshot) {
      return Group.fromSnapshot(snapshot);
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
    Uint8List imagePath,
    List<String> uuids,
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
        'recentMessageType': "",
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
      await usersRef.doc(AuthService.uid).update({
        'groups': FieldValue.arrayUnion([
          docRef.id,
        ])
      });
      for (String uuid in uuids) {
        await usersRef.doc(uuid).update({
          'groupsRequests': FieldValue.arrayUnion([
            docRef.id,
          ])
        });
      }
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
      chatList.add(Message.fromSnapshot(chat, groupId, AuthService.uid));
    }
    yield chatList; // Yield the initial list of messages

    final snapshots = groupsRef
        .doc(groupId)
        .collection('messages')
        .orderBy('time', descending: true)
        .snapshots(); // Listen to changes in the messages collection

    await for (var snapshot in snapshots) {
      for (var change in snapshot.docChanges) {
        final chat = Message.fromSnapshot(change.doc, groupId, AuthService.uid);
        if (change.type == DocumentChangeType.removed) {
          chatList.removeWhere((c) => c.id == chat.id);
          yield chatList;
        } else {
          final existingChatIndex = chatList.indexWhere((c) => c.id == chat.id);
          if (existingChatIndex != -1) {
            chatList[existingChatIndex] = chat;
          } else {
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
    // Convert the search text to lower case to make the search case-insensitive
    String lowerCaseSearchText = searchText.toLowerCase();

    // Fetch all documents from Firestore collection
    return groupsRef.snapshots().map((snapshot) {
      // Filter documents on the client side without using regex
      return snapshot.docs.where((doc) {
        // Access the 'groupName' field and convert it to lower case
        String groupName = (doc['groupName'] ?? '').toString().toLowerCase();

        // Check if the 'groupId' field is not empty
        bool validGroupId = (doc['groupId'] ?? '').toString().isNotEmpty;

        // Perform a case-insensitive substring search and check groupId
        return groupName.contains(lowerCaseSearchText) && validGroupId;
      }).toList();
    });
  }

  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      searchByUsernameStream(String searchText) {
    // Convert the search text to lower case to make the search case-insensitive
    String lowerCaseSearchText = searchText.toLowerCase();

    // Fetch all documents from Firestore collection
    return usersRef.snapshots().map((snapshot) {
      // Filter documents on the client side without using regex
      return snapshot.docs.where((doc) {
        // Access the 'username' field and convert it to lower case
        String username = (doc['username'] ?? '').toString().toLowerCase();

        // Perform a case-insensitive substring search
        return username.contains(lowerCaseSearchText);
      }).toList();
    });
  }

  static Future<void> toggleGroupJoin(String groupId) async {
    DocumentSnapshot<Map<String, dynamic>> groupDoc =
        await groupsRef.doc(groupId).get();
    bool isJoined = groupDoc['members'].contains(AuthService.uid);

    if (isJoined) {
      await Future.wait([
        groupsRef.doc(groupId).update({
          'members': FieldValue.arrayRemove([AuthService.uid])
        }),
        usersRef.doc(AuthService.uid).update({
          'groups': FieldValue.arrayRemove([groupId])
        }),
      ]);

      DocumentSnapshot<Map<String, dynamic>> groupDoc =
          await groupsRef.doc(groupId).get();
      if (groupDoc['members'].isEmpty) {
        await groupsRef.doc(groupId).delete();
      } else if (groupDoc['admin'] == AuthService.uid) {
        await groupsRef.doc(groupId).update({'admin': groupDoc['members'][0]});
      }
    } else {
      if (groupDoc['isPublic']) {
        await Future.wait([
          groupsRef.doc(groupId).update({
            'members': FieldValue.arrayUnion([AuthService.uid])
          }),
          usersRef.doc(AuthService.uid).update({
            'groups': FieldValue.arrayUnion([groupId])
          }),
          if ((await usersRef.doc(AuthService.uid).get())['groupsRequests']
              .contains(groupId))
            usersRef.doc(AuthService.uid).update({
              'groupsRequests': FieldValue.arrayRemove([groupId])
            }),
        ]);
      } else {
        if (!groupDoc['requests'].contains(AuthService.uid)) {
          await groupsRef.doc(groupId).update({
            'requests': FieldValue.arrayUnion([AuthService.uid])
          });
        } else {
          await groupsRef.doc(groupId).update({
            'requests': FieldValue.arrayRemove([AuthService.uid])
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
        'recentMessageType': message.type.toString(),
      });
    } else {
      privateChatRef.doc(id).collection('messages').add(messageMap);
      privateChatRef.doc(id).update({
        'recentMessage': message.type == Type.text ? message.content : 'Image',
        'recentMessageSender': message.sender,
        'recentMessageTime': message.time,
        'recentMessageType': message.type.toString(),
      });
    }
  }

  static Future<PrivateChat> getPrivateChatsFromMember(
      List<String> members) async {
    members.sort();
    QuerySnapshot<Object?> value =
        await privateChatRef.where("members", isEqualTo: members).get();
    if (value.docs.isEmpty) {
      return PrivateChat(members: members);
    }
    return PrivateChat.fromSnapshot(
        await privateChatRef.doc(value.docs.first.id).get());
  }

  static Stream<String?> getPrivateChatIdFromMembers(List<String> members) {
    return privateChatRef.snapshots().map((snapshot) {
      for (var doc in snapshot.docs) {
        if (doc['members'].contains(members[0]) &&
            doc['members'].contains(members[1])) {
          return doc.id;
        }
      }
      return null;
    });
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
      'recentMessageType': "",
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

  static Future<List<Group>> getGroups(String uuid) async {
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
    return groupsList;
  }

  static Stream<List<Group>> getGroupsStream() async* {
    final groupIds = await usersRef.doc(AuthService.uid).get().then((value) {
      return value['groups'];
    });

    final groupsList = <Group>[];
    Group group;
    for (var groupId in groupIds) {
      final snapshot = await groupsRef.doc(groupId).get();
      if (snapshot.exists) {
        group = Group.fromSnapshot(snapshot);
        if (group.lastMessage != null) {
          group.lastMessage!.sentByMe =
              group.lastMessage!.recentMessageSender == AuthService.uid;
          group.lastMessage!.unreadMessages =
              await getUnreadMessages(true, group.id);
        }
        groupsList.add(group);
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
          if (members!.contains(AuthService.uid) && group.id != '') {
            if (group.lastMessage != null) {
              group.lastMessage!.sentByMe =
                  group.lastMessage!.recentMessageSender == AuthService.uid;
              group.lastMessage!.unreadMessages =
                  await getUnreadMessages(true, group.id);
            }
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
    final privateChats =
        await usersRef.doc(AuthService.uid).get().then((value) {
      return value['privateChats'];
    });

    final chatsList = <PrivateChat>[];
    PrivateChat privateChat;
    for (var id in privateChats) {
      final snapshot = await privateChatRef.doc(id).get();
      if (snapshot.exists) {
        privateChat = PrivateChat.fromSnapshot(snapshot);
        privateChat.lastMessage!.sentByMe =
            privateChat.lastMessage!.recentMessageSender == AuthService.uid;
        privateChat.lastMessage!.unreadMessages =
            await getUnreadMessages(false, privateChat.id!);

        chatsList.add(privateChat);
      }
    }
    yield chatsList; // yield the initial list of private chats

    final snapshots = privateChatRef
        .snapshots(); // listen to changes in the groups collection

    await for (var snapshot in snapshots) {
      for (var change in snapshot.docChanges) {
        final id = change.doc.id;
        if (!change.doc.data()!['members'].contains(AuthService.uid)) {
          continue;
        }
        privateChat = PrivateChat.fromSnapshot(change.doc);
        if (change.type == DocumentChangeType.removed) {
          chatsList.removeWhere((g) => g.id == id);
          yield chatsList;
        } else {
          if (privateChat.members.contains(AuthService.uid)) {
            privateChat.lastMessage!.sentByMe =
                privateChat.lastMessage!.recentMessageSender == AuthService.uid;
            privateChat.lastMessage!.unreadMessages =
                await getUnreadMessages(false, privateChat.id!);
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

  static Future<DocumentSnapshot<Map<String, dynamic>>> getFollowersUser(
      String uuid) async {
    return await followersRef.doc(uuid).get();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getMembersStreamUser(
      String eventId, String detailId) {
    final stream =
        eventsRef.doc(eventId).collection('details').doc(detailId).snapshots();

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
        if (doc['requests'].contains(visitor)) {
          usersRef.doc(user).update({
            'requests': FieldValue.arrayRemove([visitor])
          });
        } else {
          usersRef.doc(user).update({
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

  static Stream<List<Message>> getPrivateChats(String? privateChatId) async* {
    if (privateChatId == null) {
      yield [];
      return;
    }
    try {
      final chats = await privateChatRef
          .doc(privateChatId)
          .collection('messages')
          .orderBy('time', descending: true)
          .get();

      final chatList = <Message>[];
      for (var chat in chats.docs) {
        chatList
            .add(Message.fromSnapshot(chat, privateChatId, AuthService.uid));
      }
      yield chatList; // Yield the initial list of messages

      final snapshots = privateChatRef
          .doc(privateChatId)
          .collection('messages')
          .orderBy('time', descending: true)
          .snapshots(); // Listen to changes in the messages collection

      await for (var snapshot in snapshots) {
        for (var change in snapshot.docChanges) {
          final chat =
              Message.fromSnapshot(change.doc, privateChatId, AuthService.uid);
          if (change.type == DocumentChangeType.removed) {
            chatList.removeWhere((c) => c.id == chat.id);
            yield chatList;
          } else {
            final existingChatIndex =
                chatList.indexWhere((c) => c.id == chat.id);
            if (existingChatIndex != -1) {
              chatList[existingChatIndex] = chat;
            } else {
              chatList.insert(0, chat);
            }
            yield chatList;
          }
        }
      }
    } catch (e) {
      debugPrint('Error while getting private chats: $e');
      yield [];
      return;
    }
  }

  static Future<int> getUnreadMessages(bool isGroup, String id) async {
    if (!isGroup) {
      var snapshot = await privateChatRef.doc(id).collection('messages').get();
      int unreadCount = 0;
      for (var doc in snapshot.docs) {
        var readBy = doc.data()['readBy'] ?? {};
        // Check if the message hasn't been read by the user
        var read = false;
        for (var value in readBy) {
          if ((AuthService.uid == value['username'])) {
            read = true;
            break;
          }
        }
        if (!read) {
          unreadCount++;
        }
      }
      return unreadCount;
    } else {
      var snapshot = await groupsRef.doc(id).collection('messages').get();
      int unreadCount = 0;
      for (var doc in snapshot.docs) {
        var readBy = doc.data()['readBy'] ?? {};
        // Check if the message hasn't been read by the user
        var read = false;
        for (var value in readBy) {
          if ((AuthService.uid == value['username'])) {
            read = true;
            break;
          }
        }
        if (!read) {
          unreadCount++;
        }
      }
      return unreadCount;
    }
  }

  static Future<void> updateMessageReadStatus(Message message) async {
    ReadBy readBy = ReadBy(readAt: Timestamp.now(), username: AuthService.uid);

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

  static Future<void> deleteMessage(Message message) async {
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
            'recentMessageType': messagesSnapshot.docs.last['type'],
          });
        } else {
          await groupsRef.doc(message.chatID).update({
            'recentMessage': '',
            'recentMessageSender': '',
            'recentMessageTime': '',
            'recentMessageType': '',
          });
        }
      }
    } else {
      try {
        await privateChatRef
            .doc(message.chatID)
            .collection('messages')
            .doc(message.id)
            .delete();
        final privateChat = (await privateChatRef.doc(message.chatID).get());
        if (privateChat.exists) {
          if (privateChat['recentMessage'] == message.content &&
              privateChat['recentMessageSender'] == message.sender &&
              privateChat['recentMessageTime'] == message.time) {
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
                'recentMessageType': messagesSnapshot.docs.last['type'],
              });
            } else {
              await privateChatRef.doc(message.chatID).delete();
              await usersRef.doc(privateChat['members'][0]).update({
                'privateChats': FieldValue.arrayRemove([message.chatID])
              });
              await usersRef.doc(privateChat['members'][1]).update({
                'privateChats': FieldValue.arrayRemove([message.chatID])
              });
            }
          }
        }
      } catch (e) {
        debugPrint('Error while deleting message: $e');
        debugPrint(e.toString());
      }
    }
  }

  static Future<void> updateMessageContent(
      Message message, String updatedMessage) async {
    Timestamp time = Timestamp.now();
    if (message.isGroupMessage) {
      await groupsRef
          .doc(message.chatID)
          .collection('messages')
          .doc(message.id)
          .update({'content': updatedMessage, 'time': time, 'readBy': []});
      await groupsRef.doc(message.chatID).update({
        'recentMessage': updatedMessage,
        'recentMessageSender': message.sender,
        'recentMessageTime': time,
        'recentMessageType': message.type.toString(),
      });
    } else {
      await privateChatRef
          .doc(message.chatID)
          .collection('messages')
          .doc(message.id)
          .update({'content': updatedMessage, 'time': time, 'readBy': []});
      await privateChatRef.doc(message.chatID).update({
        'recentMessage': updatedMessage,
        'recentMessageSender': message.sender,
        'recentMessageTime': time,
        'recentMessageType': message.type.toString(),
      });
    }
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> getUserInfo(
      String uuid) {
    try {
      return usersRef.doc(uuid).snapshots();
    } catch (e) {
      debugPrint(e.toString());
      return const Stream.empty();
    }
  }

  static Future<void> updateActiveStatus(bool isOnline) async {
    await usersRef.doc(AuthService.uid).update({
      'isOnline': isOnline,
      'lastSeen': Timestamp.now(),
    });
  }

  static void updateTyping(String id, bool isTyping) {
    usersRef.doc(AuthService.uid).update({
      'isTyping': isTyping,
      'typingTo': id,
    });
  }

  static Future<void> sendChatImage(String chatID, File file,
      bool isGroupMessage, Uint8List imagePath) async {
    final String imageUrl = await StorageService.uploadImageToStorage(
        'chat_images/$chatID/${AuthService.uid}/${Timestamp.now()}.jpg',
        imagePath);

    ReadBy readBy = ReadBy(
      readAt: Timestamp.now(),
      username: AuthService.uid,
    );

    final Message message = Message(
      content: imageUrl,
      sender: AuthService.uid,
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

  static Stream<List<dynamic>> getGroupRequestsStream(String id) {
    return groupsRef.doc(id).snapshots().map((snapshot) {
      return snapshot['requests'];
    });
  }

  static Future<List<UserData>> getGroupRequestsForGroup(String id) async {
    final docs = await groupsRef.doc(id).get();
    List<UserData> users = [];
    for (var user in docs['requests']) {
      users.add(await getUserData(user));
    }
    return users;
  }

  static Future<List<String>> getGroupRequests(String id) async {
    return (await groupsRef.doc(id).get())['requests'];
  }

  static Future<List<Group>> getUserGroupRequests(String id) async {
    final doc = await usersRef.doc(id).get();
    List<Group> groups = [];
    for (var group in doc['groupsRequests']) {
      groups.add(await getGroupFromId(group));
    }
    return groups;
  }

  static Future<List<UserData>> getFollowRequests(String id) async {
    final docs = await usersRef.doc(id).get();
    List<UserData> users = [];
    for (var user in docs['requests']) {
      users.add(await getUserData(user));
    }
    return users;
  }

  static Future<Map<String, List<String>>> getEventRequests(String id) async {
    Map<String, List<String>> requests = {};
    final det = await eventsRef.doc(id).collection('details').get();
    for (var detail in det.docs) {
      requests.putIfAbsent(detail.id, () => detail['requests']);
    }
    return requests;
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
      if ((await usersRef.doc(uuid).get())['groupsRequests'].contains(groupId))
        usersRef.doc(uuid).update({
          'groupsRequests': FieldValue.arrayRemove([groupId])
        }),
    ]);
  }

  static Stream<List<dynamic>> getGroupMessagesTypeStream(
      String id, Type type) {
    return groupsRef
        .doc(id)
        .collection('messages')
        .where("type", isEqualTo: type.toString())
        .orderBy('time', descending: true)
        .snapshots()
        .map((s) => s.docs);
  }

  static Stream<List<dynamic>> getPrivateMessagesTypeStream(
      String id, Type type) {
    return privateChatRef
        .doc(id)
        .collection('messages')
        .where("type", isEqualTo: type.toString())
        .orderBy('time', descending: true)
        .snapshots()
        .map((s) => s.docs);
  }

  static Future<List<Message>> getGroupMessagesType(
      String id, Type type) async {
    final docs = (await groupsRef
            .doc(id)
            .collection('messages')
            .where("type", isEqualTo: type.toString())
            .orderBy('time', descending: true)
            .get())
        .docs;

    List<Message> messages = [];
    for (var doc in docs) {
      messages.add(Message.fromSnapshot(doc, id, AuthService.uid));
      if (type == Type.event) {
        //check if the event is still valid
        final event = await eventsRef.doc(doc['content']).get();
        if (!event.exists) {
          debugPrint('Event does not exist');
          messages.removeWhere((element) => element.id == doc.id);
        }
      }
    }
    return messages;
  }

  static Future<List<Message>> getPrivateMessagesType(
      String id, Type type) async {
    final docs = (await privateChatRef
            .doc(id)
            .collection('messages')
            .where("type", isEqualTo: type.toString())
            .orderBy('time', descending: true)
            .get())
        .docs;
    List<Message> messages = [];
    for (var doc in docs) {
      messages.add(Message.fromSnapshot(doc, id, AuthService.uid));
    }
    return messages;
  }

  static Future<void> acceptUserRequest(
    String user,
  ) async {
    await Future.wait([
      usersRef.doc(AuthService.uid).update({
        'requests': FieldValue.arrayRemove([user])
      }),
      followersRef.doc(AuthService.uid).update({
        'followers': FieldValue.arrayUnion([user])
      }),
      followersRef.doc(user).update({
        'following': FieldValue.arrayUnion([AuthService.uid])
      }),
    ]);
  }

  static Future<void> denyUserRequest(
    String user,
  ) async {
    await usersRef.doc(AuthService.uid).update({
      'requests': FieldValue.arrayRemove([user])
    });
  }

  static Future<void> acceptEventRequest(
      String eventId, String detailId, String uuid) async {
    await Future.wait([
      eventsRef.doc(eventId).collection('details').doc(detailId).update({
        'members': FieldValue.arrayUnion([uuid]),
      }),
      if ((await eventsRef
              .doc(eventId)
              .collection('details')
              .doc(detailId)
              .get())['requests']
          .contains(uuid))
        eventsRef.doc(eventId).collection('details').doc(detailId).update({
          'requests': FieldValue.arrayRemove([uuid])
        }),
    ]);
  }

  static Future<void> denyUserGroupRequest(String groupId, String uuid) async {
    await usersRef.doc(uuid).update({
      'groupsRequests': FieldValue.arrayRemove([groupId])
    });
  }

  static Future<void> acceptUserGroupRequest(
    String groupId,
  ) async {
    await Future.wait([
      groupsRef.doc(groupId).update({
        'members': FieldValue.arrayUnion([AuthService.uid]),
      }),
      usersRef.doc(AuthService.uid).update({
        'groupsRequests': FieldValue.arrayRemove([groupId])
      }),
      if ((await groupsRef.doc(groupId).get())['requests']
          .contains(AuthService.uid))
        groupsRef.doc(groupId).update({
          'requests': FieldValue.arrayRemove([groupId])
        }),
    ]);
  }

  static Future<void> createEvent(Event event, Uint8List imagePath,
      List<String> uuids, List<String> groupIds) async {
    try {
      DocumentReference docRef = await eventsRef.add(Event.toMap(event));

      for (Details details in event.details!) {
        await docRef.collection('details').add(Details.toMap(details));
      }

      //get ids from the details
      final docs = await docRef.collection('details').get();

      String imageUrl = imagePath.toString() == '[]'
          ? ''
          : await StorageService.uploadImageToStorage(
              'event_images/${docRef.id}.jpg', imagePath);

      await eventsRef.doc(docRef.id).update({
        'imagePath': imageUrl,
        'eventId': docRef.id,
        'createdAt': Timestamp.now(),
      });

      for (var doc in docs.docs) {
        await usersRef.doc(AuthService.uid).update({
          'events': FieldValue.arrayUnion([
            '${docRef.id}:${doc.id}',
          ])
        });
      }
      await sendEventsOnGroups(docRef.id, groupIds);
      await sendEventsOnPrivateChat(docRef.id, uuids);
    } catch (e) {
      debugPrint("Error while creating the event: $e");
    }
  }

  static Future<void> sendEventsOnGroups(
      String eventId, List<String> groupIds) async {
    Message message = Message(
      content: eventId,
      sender: AuthService.uid,
      isGroupMessage: true,
      time: Timestamp.now(),
      type: Type.event,
      readBy: [
        ReadBy(
          readAt: Timestamp.now(),
          username: AuthService.uid,
        ),
      ],
    );

    for (var id in groupIds) {
      await groupsRef.doc(id).collection('messages').add(
            message.toMap(),
          );
      await groupsRef.doc(id).update({
        'recentMessage': 'Event',
        'recentMessageSender': message.sender,
        'recentMessageTime': message.time,
        'recentMessageType': message.type.toString(),
      });
    }
  }

  static Future<void> sendEventsOnPrivateChat(
      String eventId, List<String> uuids) async {
    Message message = Message(
      content: eventId,
      sender: AuthService.uid,
      isGroupMessage: false,
      time: Timestamp.now(),
      type: Type.event,
      readBy: [
        ReadBy(
          readAt: Timestamp.now(),
          username: AuthService.uid,
        ),
      ],
    );

    for (var uuid in uuids) {
      final PrivateChat privateChat =
          await getPrivateChatsFromMember([uuid, AuthService.uid]);
      if (privateChat.id == null) {
        final id = await createPrivateChat(privateChat);
        privateChat.id = id;
      }
      await Future.wait([
        privateChatRef.doc(privateChat.id).collection('messages').add(
              message.toMap(),
            ),
        privateChatRef.doc(privateChat.id).update({
          'recentMessage': 'Event',
          'recentMessageSender': message.sender,
          'recentMessageTime': message.time,
          'recentMessageType': message.type.toString(),
        }),
      ]);
    }
  }

  static Stream<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      searchByEventNameStream(String searchText) {
    // Convert the search text to lower case to make the search case-insensitive
    String lowerCaseSearchText = searchText.toLowerCase();

    // Fetch all documents from Firestore collection
    return eventsRef.snapshots().map((snapshot) {
      // Filter documents on the client side without using regex
      return snapshot.docs.where((doc) {
        // Access the 'name' field and convert it to lower case
        String eventName = (doc['name'] ?? '').toString().toLowerCase();

        // Check if the 'eventId' field is not empty
        bool validEventId = (doc['eventId'] ?? '').toString().isNotEmpty;

        // Perform a case-insensitive substring search and check eventId
        return eventName.contains(lowerCaseSearchText) && validEventId;
      }).toList();
    });
  }

  static Future<void> toggleEventJoin(
    String eventId,
    String detailId,
  ) async {
    DocumentSnapshot<Map<String, dynamic>> eventDoc =
        await eventsRef.doc(eventId).get();
    DocumentSnapshot<Map<String, dynamic>> detailDoc =
        await eventsRef.doc(eventId).collection('details').doc(detailId).get();

    if (!DateTime.now().isBefore(DateTime(
      detailDoc['startDate'].toDate().year,
      detailDoc['startDate'].toDate().month,
      detailDoc['startDate'].toDate().day,
      detailDoc['startTime'].toDate().hour,
      detailDoc['startTime'].toDate().minute,
    ))) {
      return;
    }
    debugPrint('Event ID: $eventId');
    bool isJoined = detailDoc['members'].contains(AuthService.uid);
    debugPrint('Is joined: $isJoined');
    if (isJoined) {
      await Future.wait([
        eventsRef.doc(eventId).collection('details').doc(detailId).update({
          'members': FieldValue.arrayRemove([AuthService.uid])
        }),
        usersRef.doc(AuthService.uid).update({
          'events': FieldValue.arrayRemove(["$eventId:$detailId"])
        }),
      ]);
    } else {
      if (eventDoc['isPublic']) {
        await Future.wait([
          eventsRef.doc(eventId).collection('details').doc(detailId).update({
            'members': FieldValue.arrayUnion([AuthService.uid])
          }),
          usersRef.doc(AuthService.uid).update({
            'events': FieldValue.arrayUnion(["$eventId:$detailId"])
          }),
          if ((await usersRef.doc(AuthService.uid).get())['eventsRequests']
              .contains("$eventId:$detailId"))
            usersRef.doc(AuthService.uid).update({
              'eventsRequests': FieldValue.arrayRemove(["$eventId:$detailId"])
            }),
        ]);
      } else {
        if (!detailDoc['requests'].contains(AuthService.uid)) {
          await eventsRef
              .doc(eventId)
              .collection('details')
              .doc(detailId)
              .update({
            'requests': FieldValue.arrayUnion([AuthService.uid])
          });
        } else {
          await eventsRef
              .doc(eventId)
              .collection('details')
              .doc(detailId)
              .update({
            'requests': FieldValue.arrayRemove([AuthService.uid])
          });
        }
      }
    }
  }

  static Stream<Event> getEventStream(String eventId) {
    // Assuming you're using Firestore or any other database service
    return FirebaseFirestore.instance
        .collection('events')
        .doc(eventId)
        .snapshots()
        .asyncMap((snapshot) async {
      if (snapshot.exists) {
        return await Event.fromSnapshot(snapshot);
      } else {
        throw Exception('Event not found');
      }
    });
  }

  static Future<List<Event>> getCreatedEvents(String uuid) async {
    final ids = await usersRef.doc(uuid).get().then((value) {
      return value['events'];
    });
    final eventsIds = [];
    ids.forEach((element) {
      eventsIds.add(element.split(':')[0]);
    });

    final eventsList = <Event>[];

    for (var eventId in eventsIds) {
      final snapshot = await eventsRef.doc(eventId).get();
      if (snapshot.exists) {
        Event event = await Event.fromSnapshot(snapshot);
        if (event.admin == uuid) {
          eventsList.add(event);
        }
      }
    }
    eventsList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return eventsList;
  }

  static Future<List<Event>> getJoinedEvents(String uuid) async {
    final ids = await usersRef.doc(uuid).get().then((value) {
      return value['events'];
    });
    final eventsIds = [];
    ids.forEach((element) {
      eventsIds.add(element.split(':')[0]);
    });
    final eventsList = <Event>[];

    for (var eventId in eventsIds) {
      final snapshot = await eventsRef.doc(eventId).get();
      if (snapshot.exists) {
        Event event = await Event.fromSnapshot(snapshot);
        if (event.admin != uuid &&
            !eventsList.any((element) => element.id == event.id)) {
          eventsList.add(event);
        }
      }
    }
    eventsList.sort((a, b) => b.createdAt!.compareTo(a.createdAt!));
    return eventsList;
  }

  static Future<bool> checkIfJoined(
      bool isGroup, String? id, String uuid) async {
    if (id == null) return false;
    if (isGroup) {
      final doc = await groupsRef.doc(id).get();
      return (doc['members'].contains(uuid));
    } else {
      final doc = await eventsRef.doc(id).get();
      return (await Event.fromSnapshot(doc))
          .details!
          .any((element) => element.members!.contains(uuid));
    }
  }

  static shareNewsOnGroups(String title, String description, String imageUrl,
      String blogUrl, String id) async {
    Message message = Message(
      content: '$title\n$description\n$blogUrl\n$imageUrl',
      sender: AuthService.uid,
      isGroupMessage: true,
      time: Timestamp.now(),
      type: Type.news,
      readBy: [
        ReadBy(
          readAt: Timestamp.now(),
          username: AuthService.uid,
        ),
      ],
    );
    return await Future.wait([
      groupsRef.doc(id).collection('messages').add(
            message.toMap(),
          ),
      groupsRef.doc(id).update({
        'recentMessage': 'News',
        'recentMessageSender': message.sender,
        'recentMessageTime': message.time,
        'recentMessageType': message.type.toString(),
      }),
    ]);
  }

  static shareNewsOnFollower(
    String title,
    String description,
    String imageUrl,
    String blogUrl,
    String uid,
  ) async {
    Message message = Message(
      content: '$title\n$description\n$blogUrl\n$imageUrl',
      sender: AuthService.uid,
      isGroupMessage: false,
      time: Timestamp.now(),
      type: Type.news,
      readBy: [
        ReadBy(
          readAt: Timestamp.now(),
          username: AuthService.uid,
        ),
      ],
    );
    final PrivateChat privateChat = await getPrivateChatsFromMember(
        [uid, FirebaseAuth.instance.currentUser!.uid]);

    if (privateChat.id == null) {
      final id = await createPrivateChat(privateChat);
      privateChat.id = id;
    }
    return await Future.wait([
      privateChatRef.doc(privateChat.id).collection('messages').add(
            message.toMap(),
          ),
      privateChatRef.doc(privateChat.id).update({
        'recentMessage': 'News',
        'recentMessageSender': message.sender,
        'recentMessageTime': message.time,
        'recentMessageType': message.type.toString(),
      }),
    ]);
  }

  static Future<void> updateEvent(Event event, Uint8List uint8list,
      bool sameImage, bool visibilityHasChanged, List<String> uuids) async {
    await eventsRef.doc(event.id).update(Event.toMap(event));

    for (Details detail in event.details!) {
      if (detail.id == null) {
        await eventsRef
            .doc(event.id)
            .collection('details')
            .add(Details.toMap(detail));
      } else {
        await eventsRef
            .doc(event.id)
            .collection('details')
            .doc(detail.id)
            .update(Details.toMap(detail));
      }
    }

    if (!sameImage) {
      String imageUrl = uint8list.toString() == '[]' || uint8list.isEmpty
          ? ''
          : await StorageService.uploadImageToStorage(
              'event_images/${event.id}.jpg', uint8list);
      await eventsRef.doc(event.id).update({
        'imagePath': imageUrl,
      });
    }

    List<String> members = [];
    for (Details detail in event.details!) {
      members.addAll(detail.members!);
    }

    if (visibilityHasChanged && event.isPublic) {
      Map<String, List<String>> requests = await getEventRequests(event.id!);
      for (var key in requests.keys) {
        List<String> ids = requests[key]!;
        for (var id in ids) {
          await acceptEventRequest(event.id!, key, id);
          members.add(id);
        }
      }
    }
    for (var id in uuids) {
      if (!members.contains(id)) {
        await usersRef.doc(id).update({
          'eventsRequests': FieldValue.arrayUnion([event.id])
        });
      }
    }
  }

  static Future<Event> getEvent(String id) {
    return eventsRef.doc(id).get().then((value) {
      return Event.fromSnapshot(value);
    });
  }

  static updateGroup(Group group, Uint8List uint8list, bool sameImage,
      bool visibilityHasChanged, List<String> uuids) async {
    await groupsRef.doc(group.id).update(Group.toMap(group));
    if (!sameImage) {
      String imageUrl = uint8list.toString() == '[]' || uint8list.isEmpty
          ? ''
          : await StorageService.uploadImageToStorage(
              'group_images/${group.id}.jpg', uint8list);
      await groupsRef.doc(group.id).update({
        'groupImage': imageUrl,
      });
    }
    List<String> members = group.members!;
    if (visibilityHasChanged && group.isPublic) {
      List<String> requests = await getGroupRequests(group.id);
      for (var id in requests) {
        await acceptGroupRequest(group.id, id);
        members.add(id);
      }
    }
    for (var id in uuids) {
      if (!members.contains(id)) {
        await usersRef.doc(id).update({
          'groupsRequests': FieldValue.arrayUnion([group.id])
        });
      }
    }
  }

  static Future<void> deletePrivateChat(PrivateChat chat) async {
    try {
      await usersRef.doc(chat.members[0]).update({
        'privateChats': FieldValue.arrayRemove([chat.id])
      });
    } catch (e) {
      debugPrint("User doesn't exists: ${chat.members[0]}");
    }
    try {
      await usersRef.doc(chat.members[1]).update({
        'privateChats': FieldValue.arrayRemove([chat.id])
      });
    } catch (e) {
      debugPrint("User doesn't exists:${chat.members[1]}");
    }
    return await privateChatRef.doc(chat.id!).delete();
  }

  static Future<void> deleteDetail(String eventId, String detailId) async {
    final details =
        await eventsRef.doc(eventId).collection('details').doc(detailId).get();

    details['members'].forEach((element) async {
      await usersRef.doc(element).update({
        'events': FieldValue.arrayRemove(["$eventId:$detailId"])
      });
    });

    await eventsRef.doc(eventId).collection('details').doc(detailId).delete();

    debugPrint('Detail deleted');

    if ((await eventsRef.doc(eventId).collection('details').get())
        .docs
        .isEmpty) {
      await eventsRef.doc(eventId).delete();
    }
  }

  static Future<void> deleteEvent(String eventId) async {
    final details = await eventsRef.doc(eventId).collection('details').get();
    for (var detail in details.docs) {
      await deleteDetail(eventId, detail.id);
    }
    await eventsRef.doc(eventId).delete();
  }

  static Future<void> deleteUser() async {
    final userDoc = await usersRef.doc(AuthService.uid).get();
    //exit all groups
    for (var group in userDoc['groups']) {
      await toggleGroupJoin(
        group,
      );
    }
    //exit all events
    for (var event in userDoc['events']) {
      final eventId = event.split(':')[0];
      final detailId = event.split(':')[1];

      final docEvent = await eventsRef.doc(eventId).get();
      if (docEvent.exists && docEvent['admin'] == AuthService.uid) {
        await deleteEvent(eventId);
      } else {
        final doc = await eventsRef
            .doc(eventId)
            .collection('details')
            .doc(detailId)
            .get();

        if (doc.exists) {
          await eventsRef
              .doc(eventId)
              .collection('details')
              .doc(detailId)
              .update({
            'members': FieldValue.arrayRemove([AuthService.uid])
          });
        }
      }
    }
    final followerDoc = await followersRef.doc(AuthService.uid).get();

    //exit all following
    for (var following in followerDoc['following']) {
      await toggleFollowUnfollow(following, AuthService.uid);
    }
    //exit all followers
    for (var follower in followerDoc['followers']) {
      await toggleFollowUnfollow(AuthService.uid, follower);
    }
    await followersRef.doc(AuthService.uid).delete();

    //delete photo
    if (userDoc['imageUrl'] != '') {
      await StorageService.deleteImageFromStorage(userDoc['imageUrl']);
    }

    //delete user
    await usersRef.doc(AuthService.uid).delete();
  }
}
