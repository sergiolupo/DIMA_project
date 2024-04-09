import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/storage_service.dart';
import 'package:dima_project/widgets/home/binaryoption_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class SearchPage extends StatefulWidget {
  final UserData user;
  const SearchPage({super.key, required this.user});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late final StreamController<QuerySnapshot> _searchStreamController =
      StreamController<QuerySnapshot>();

  StreamSubscription<QuerySnapshot>? _searchStreamSubscription;

  bool searchUsers = false;

  @override
  void initState() {
    super.initState();
  }

  void _initiateSearchMethod() {
    final searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      _searchStreamSubscription?.cancel();

      if (searchUsers) {
        _searchStreamSubscription =
            DatabaseService.searchByUsernameStream(searchText)
                .listen((snapshot) {
          _searchStreamController.add(snapshot);
        });
      } else {
        _searchStreamSubscription =
            DatabaseService.searchByGroupNameStream(searchText)
                .listen((snapshot) {
          _searchStreamController.add(snapshot);
        });
      }
    }
  }

  Future<UserData> convertToUserData(DocumentSnapshot documentSnapshot) async {
    return UserData(
      name: documentSnapshot['name'],
      surname: documentSnapshot['surname'],
      username: documentSnapshot['username'],
      email: documentSnapshot['email'],
      password: '',
      imagePath: await StorageService.downloadImageFromStorage(
          documentSnapshot['imageUrl']),
      categories: (documentSnapshot['selectedCategories'] as List<dynamic>)
          .map((categoryMap) => categoryMap['value'].toString())
          .toList()
          .cast<String>(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          "Search",
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
        backgroundColor: CupertinoTheme.of(context).primaryColor,
      ),
      child: Column(
        children: [
          Container(
            color: CupertinoTheme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _searchController,
                    onChanged: (_) => _initiateSearchMethod(),
                    placeholder:
                        "Search${searchUsers ? " users" : " groups"}...",
                    placeholderStyle:
                        const TextStyle(color: CupertinoColors.white),
                    style: const TextStyle(color: CupertinoColors.white),
                    decoration: BoxDecoration(border: Border.all(width: 0)),
                  ),
                ),
                GestureDetector(
                  onTap: _initiateSearchMethod,
                  child: Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withOpacity(1.0),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      CupertinoIcons.search,
                      color: CupertinoColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          CustomBinaryOption(
            textLeft: "Groups",
            textRight: "Users",
            onChanged: (value) {
              setState(() {
                searchUsers = value;
                _initiateSearchMethod();
              });
            },
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _searchStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text("No ${searchUsers ? "users" : "groups"} found"),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    return searchUsers
                        ? ((docs[index].data() as Map<String, dynamic>)
                                .containsKey('email'))
                            ? FutureBuilder<UserData>(
                                future: convertToUserData(docs[index]),
                                builder: (context, userSnapshot) {
                                  if (userSnapshot.connectionState ==
                                      ConnectionState.waiting) {
                                    return const Center(
                                      child: CupertinoActivityIndicator(
                                        radius: 16,
                                      ),
                                    );
                                  } else if (userSnapshot.hasError) {
                                    return Text('Error: ${userSnapshot.error}');
                                  } else {
                                    final userData = userSnapshot.data!;
                                    return SearchTile(
                                      user: userData,
                                      group: null,
                                      searchUsers: true,
                                    );
                                  }
                                },
                              )
                            : const SizedBox()
                        : ((docs[index].data() as Map<String, dynamic>)
                                .containsKey('groupId'))
                            ? SearchTile(
                                user: widget.user,
                                group: Group(
                                  id: docs[index]['groupId'],
                                  name: docs[index]['groupName'],
                                  admin: docs[index]['admin'],
                                ),
                                searchUsers: false,
                              )
                            : const SizedBox();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchStreamController.close(); // Close the stream controller
    _searchStreamSubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }
}

class SearchTile extends StatelessWidget {
  final UserData user;
  final Group? group;
  final bool searchUsers;
  const SearchTile({
    super.key,
    required this.user,
    this.group,
    required this.searchUsers,
  });

  @override
  Widget build(BuildContext context) {
    return searchUsers ? _buildUserTile() : _buildGroupTile();
  }

  Widget _buildUserTile() {
    return CupertinoListTile(
      leading: ClipOval(
        child: Container(
          width: 100,
          height: 100,
          color: CupertinoColors.lightBackgroundGray,
          child: user.imagePath != null
              ? Image.memory(
                  user.imagePath!,
                  fit: BoxFit.cover,
                )
              : const Icon(
                  CupertinoIcons.photo,
                  size: 50,
                  color: CupertinoColors.systemGrey,
                ),
        ),
      ),
      title: Text(
        user.username,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text("${user.name} ${user.surname}"),
    );
  }

  Widget _buildGroupTile() {
    return CupertinoListTile(
      leading: ClipOval(
        child: Text(
          group!.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: CupertinoColors.white),
        ),
      ),
      title: Text(
        group!.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text("Admin ${group!.admin}"),
      trailing: GroupJoinButton(
        user: user,
        group: group!,
      ),
    );
  }
}

class GroupJoinButton extends StatefulWidget {
  final UserData user;
  final Group group;

  const GroupJoinButton({
    super.key,
    required this.user,
    required this.group,
  });

  @override
  GroupJoinButtonState createState() => GroupJoinButtonState();
}

class GroupJoinButtonState extends State<GroupJoinButton> {
  late bool _isJoined;

  @override
  void initState() {
    super.initState();
    _isJoined = false; // Initialize _isJoined state
    _checkIfJoined(); // Check if user is already joined when widget is initialized
  }

  void _checkIfJoined() async {
    try {
      await DatabaseService.isUserJoined(
        widget.group.id,
        widget.user.username,
      ).then((isJoined) {
        if (mounted) {
          setState(() {
            _isJoined = isJoined;
          });
        }
      });
    } catch (error) {
      debugPrint("Error occurred: $error");
      if (mounted) {
        setState(() {
          _isJoined = false; // Handle error by setting _isJoined to false
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          await DatabaseService.toggleGroupJoin(
            widget.group.id,
            FirebaseAuth.instance.currentUser!.uid,
            widget.user.username,
          );
          if (mounted) {
            setState(() {
              _checkIfJoined();
            });
          }
        } catch (error) {
          debugPrint("Error occurred: $error");
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: CupertinoTheme.of(context).primaryColor,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: CupertinoColors.white),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Text(
          _isJoined ? "Joined" : "Join Now",
          style: const TextStyle(color: CupertinoColors.white),
        ),
      ),
    );
  }
}
