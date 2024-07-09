import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/group_tile.dart';
import 'package:flutter/cupertino.dart';

class ShowGroupsPage extends StatefulWidget {
  final String user;
  final String uuid;
  const ShowGroupsPage({
    super.key,
    required this.user,
    required this.uuid,
  });

  @override
  ShowGroupsPageState createState() => ShowGroupsPageState();
}

class ShowGroupsPageState extends State<ShowGroupsPage> {
  late StreamSubscription<List<QueryDocumentSnapshot<Map<String, dynamic>>>>?
      _groupsStreamSubscription;
  late final StreamController<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _groupsStreamController =
      StreamController<List<QueryDocumentSnapshot<Map<String, dynamic>>>>();
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    _groupsStreamSubscription =
        DatabaseService.getGroupsStreamUser(widget.user).listen((snapshot) {
      _groupsStreamController.add(snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        middle: const Text('Groups'),
      ),
      child: SafeArea(
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(8),
            height: 50,
            child: CupertinoTextField(
              controller: _searchController,
              onChanged: (_) => (setState(() {
                _searchText = _searchController.text;
              })),
              prefix: const Icon(CupertinoIcons.search,
                  color: CupertinoColors.systemPink),
              decoration: BoxDecoration(border: Border.all(width: 0)),
            ),
          ),
          StreamBuilder<List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
            stream: _groupsStreamController.stream,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData) {
                return const CupertinoActivityIndicator();
              }

              final docs = snapshot.data;
              if (docs == null || docs.isEmpty) {
                return const Center(
                  child: Text('No groups'),
                );
              }
              int i = 0;
              return ListView.builder(
                itemCount: docs.length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  final group = Group.fromSnapshot(docs[index]);
                  if (!RegExp(_searchText, caseSensitive: false)
                      .hasMatch(group.name)) {
                    i += 1;
                    if (i == docs.length) {
                      return const Center(
                        child: Text('No groups found'),
                      );
                    }
                    return const SizedBox.shrink();
                  }
                  return FutureBuilder(
                      future: DatabaseService.getUserData(group.admin!),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CupertinoActivityIndicator();
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final admin = snapshot.data!.username;
                          group.admin = admin;
                          return GroupTile(
                              uuid: widget.uuid,
                              group: group,
                              isJoined: group.members!.contains(widget.uuid)
                                  ? 1
                                  : group.requests!.contains(widget.uuid)
                                      ? 2
                                      : 0);
                        }
                      });
                },
              );
            },
          ),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    _groupsStreamSubscription?.cancel();
    _groupsStreamController.close();
    super.dispose();
  }
}
