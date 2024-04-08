import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/helper_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late final StreamController<QuerySnapshot> _searchStreamController =
      StreamController<QuerySnapshot>();
  UserData? _user;
  StreamSubscription<QuerySnapshot>? _searchStreamSubscription;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  void _getUserData() async {
    final uid = await HelperFunctions.getUid();
    final userData = await DatabaseService.getUserData(uid!);
    setState(() {
      _user = userData;
    });
  }

  void _initiateSearchMethod() {
    final searchText = _searchController.text.trim();
    if (searchText.isNotEmpty) {
      // Cancel the previous subscription if it exists
      _searchStreamSubscription?.cancel();
      // Add a new stream subscription
      _searchStreamSubscription =
          DatabaseService.searchByNameStream(searchText).listen((snapshot) {
        _searchStreamController.add(snapshot);
      });
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
                    placeholder: "Search groups...",
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
                  return const Center(
                    child: Text("No groups found"),
                  );
                }
                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final group = Group(
                      id: docs[index]['groupId'],
                      name: docs[index]['groupName'],
                      admin: docs[index]['admin'],
                    );
                    return GroupSearchTile(
                      user: _user!,
                      group: group,
                    );
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
    _searchStreamController.close();
    _searchStreamSubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }
}

class GroupSearchTile extends StatelessWidget {
  final UserData user;
  final Group group;

  const GroupSearchTile({
    super.key,
    required this.user,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      leading: ClipOval(
        child: Text(
          group.name.substring(0, 1).toUpperCase(),
          style: const TextStyle(color: CupertinoColors.white),
        ),
      ),
      title: Text(
        group.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text("Admin: ${group.admin}"),
      trailing: GroupJoinButton(user: user, group: group),
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
  bool _isJoined = false;

  @override
  void initState() {
    super.initState();
    _checkIfJoined();
  }

  void _checkIfJoined() {
    DatabaseService.isUserJoined(widget.group.id, widget.user.username)
        .then((value) {
      if (mounted) {
        setState(() {
          _isJoined = value; // Use default value if value is null
        });
      }
    }).catchError((error) {
      debugPrint("Error occurred: $error");
      if (mounted) {
        setState(() {
          _isJoined = false; // Handle error by setting _isJoined to false
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await DatabaseService.toggleGroupJoin(
          widget.group.id,
          FirebaseAuth.instance.currentUser!.uid,
          widget.user.username,
        );
        if (mounted) {
          setState(() {
            _isJoined = !_isJoined;
          });
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
