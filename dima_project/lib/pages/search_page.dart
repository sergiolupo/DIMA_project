import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/group_tile.dart';
import 'package:dima_project/widgets/home/selectoption_widget.dart';
import 'package:dima_project/widgets/home/user_tile.dart';
import 'package:flutter/cupertino.dart';

class SearchPage extends StatefulWidget {
  final UserData user;
  const SearchPage({super.key, required this.user});

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  late final StreamController<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _searchStreamController =
      StreamController<List<QueryDocumentSnapshot<Map<String, dynamic>>>>();

  StreamSubscription<List<QueryDocumentSnapshot<Map<String, dynamic>>>>?
      _searchStreamSubscription;

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
                        "Search${searchIdx == 0 ? " users" : searchIdx == 1 ? " groups" : " events"}...",
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
            child: StreamBuilder<
                List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              stream: _searchStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final docs = snapshot.data ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                        "No ${searchIdx == 0 ? "users" : searchIdx == 1 ? "groups" : "events"} found"),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    if (searchIdx == 0 &&
                        (docs[index].data()).containsKey('email')) {
                      final userData = UserData.fromSnapshot(docs[index]);
                      return UserTile(user: userData, visitor: widget.user);
                    } else if (searchIdx != 0 &&
                        (docs[index].data()).containsKey('groupId')) {
                      final group = Group.fromSnapshot(docs[index]);
                      return GroupTile(
                        user: widget.user,
                        group: group,
                        isJoined: group.members!.contains(widget.user.username),
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
