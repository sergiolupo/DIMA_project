import 'package:dima_project/models/group.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/user_group_request_tile.dart';
import 'package:flutter/cupertino.dart';

class GroupsRequestsPage extends StatefulWidget {
  final String uuid;
  const GroupsRequestsPage({super.key, required this.uuid});
  @override
  GroupsRequestsPageState createState() => GroupsRequestsPageState();
}

class GroupsRequestsPageState extends State<GroupsRequestsPage> {
  Stream<List<dynamic>>? groupsRequests;
  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    groupsRequests = DatabaseService.getUserGroupRequests(widget.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return groupsRequests == null
        ? const Center(child: CupertinoActivityIndicator())
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: const Text('Group Requests'),
              leading: CupertinoButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: const EdgeInsets.only(left: 10),
                child: const Icon(CupertinoIcons.back),
              ),
            ),
            child: SafeArea(
              child: StreamBuilder<List<dynamic>>(
                stream: groupsRequests,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List requests =
                        snapshot.data!.map((doc) => doc).toList();
                    return ListView.builder(
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          return StreamBuilder<Group>(
                            stream: DatabaseService.getGroupFromId(
                              requests[index],
                            ),
                            builder: (context, snapshot) {
                              debugPrint("Snapshot: $snapshot");
                              if (snapshot.hasData) {
                                final group = snapshot.data!;
                                return UserGroupRequestTile(
                                    group: group, uuid: widget.uuid);
                              } else {
                                return const Center(
                                  child: CupertinoActivityIndicator(),
                                );
                              }
                            },
                          );
                        });
                  } else {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }
                },
              ),
            ),
          );
  }
}
