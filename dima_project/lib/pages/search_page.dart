import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/selectoption_widget.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';

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

  int searchIdx = 0;

  @override
  void initState() {
    super.initState();
  }

  void _initiateSearchMethod() {
    final searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      _searchStreamSubscription?.cancel();

      if (searchIdx == 0) {
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
                        "Search${searchIdx == 0 ? " users" : " groups"}...",
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
          CustomSelectOption(
            textLeft: "Users",
            textRight: "Events",
            textMiddle: "Groups",
            onChanged: (value) {
              setState(() {
                searchIdx = value;
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
                    child:
                        Text("No ${searchIdx == 0 ? "users" : "groups"} found"),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    if (searchIdx == 0 &&
                        (docs[index].data() as Map<String, dynamic>)
                            .containsKey('email')) {
                      final userData = UserData.convertToUserData(docs[index]);
                      return SearchTile(
                        user: userData,
                        group: null,
                        searchUsers: true,
                        myUsername: widget.user.username,
                      );
                    } else if (searchIdx != 0 &&
                        (docs[index].data() as Map<String, dynamic>)
                            .containsKey('groupId')) {
                      final group = Group.convertToGroup(docs[index]);
                      return SearchTile(
                        user: widget.user,
                        group: group,
                        searchUsers: false,
                        myUsername: widget.user.username,
                      );
                    } else {
                      return Container();
                    }
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
  final String? myUsername;
  const SearchTile({
    super.key,
    required this.user,
    this.group,
    this.myUsername,
    required this.searchUsers,
  });

  @override
  Widget build(BuildContext context) {
    return searchUsers ? _buildUserTile(context) : _buildGroupTile();
  }

  Widget _buildUserTile(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.go('/userprofile',
            extra: {"user": user, "isMyProfile": myUsername == user.username});
      },
      child: CupertinoListTile(
        leading: ClipOval(
          child: Container(
            width: 100,
            height: 100,
            color: CupertinoColors.lightBackgroundGray,
            child: CreateImageWidget.getUserImage(user.imagePath!),
          ),
        ),
        title: Text(
          user.username,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${user.name} ${user.surname}"),
      ),
    );
  }

  Widget _buildGroupTile() {
    return GroupTile(user: user, group: group!);
  }
}

class GroupTile extends StatefulWidget {
  final UserData user;
  final Group group;

  const GroupTile({
    super.key,
    required this.user,
    required this.group,
  });

  @override
  GroupTileState createState() => GroupTileState();
}

class GroupTileState extends State<GroupTile> {
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
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (_isJoined) {
                context.go('/chat',
                    extra: {"group": widget.group, "user": widget.user});
              }
            },
            child: CupertinoListTile(
              leading: CreateImageWidget.getGroupImage(widget.group.imagePath!),
              title: Text(
                widget.group.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Admin: ${widget.group.admin}"),
            ),
          ),
        ),
        GestureDetector(
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
            padding: const EdgeInsets.only(right: 20),
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
          ),
        ),
      ],
    );
  }
}
