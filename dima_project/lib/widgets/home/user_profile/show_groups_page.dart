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
  late Stream<List<Group>> groupsStream;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    groupsStream = DatabaseService.getGroupsStream(widget.user.uuid!);
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
      child: StreamBuilder<List<Group>>(
        stream: groupsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final docs = snapshot.data ?? [];
          if (docs.isEmpty &&
              snapshot.connectionState == ConnectionState.active) {
            return const Center(
              child: Text("No groups found"),
            );
          }

          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final group = docs[index];
              return FutureBuilder(
                  future: DatabaseService.getUserData(group.admin!),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CupertinoActivityIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final admin = snapshot.data!.username;
                      group.admin = admin;
                      return GroupTile(
                        user: widget.user,
                        group: group,
                        visitor: widget.visitor,
                        isJoined: widget.visitor != null
                            ? group.members!.contains(widget.visitor!.uuid!)
                            : group.members!.contains(widget.user.uuid!),
                      );
                    }
                  });
            },
          );
        },
      ),
    );
  }
}
