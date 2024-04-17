import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/group_tile.dart';
import 'package:flutter/cupertino.dart';

class ShowGroupsPage extends StatefulWidget {
  final UserData user;
  final UserData? visitor;
  const ShowGroupsPage({
    super.key,
    required this.user,
    this.visitor,
  });

  @override
  ShowGroupsPageState createState() => ShowGroupsPageState();
}

class ShowGroupsPageState extends State<ShowGroupsPage> {
  late Stream<List<DocumentSnapshot<Map<String, dynamic>>>> groupsStream;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    groupsStream = DatabaseService.getGroupsStream(widget.user.username);
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
      child: StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
        stream: groupsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final docs = snapshot.data ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text("No groups found"),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final group = Group.convertToGroup(docs[index]);
              return GroupTile(
                user: widget.user,
                group: group,
                visitor: widget.visitor,
              );
            },
          );
        },
      ),
    );
  }
}
