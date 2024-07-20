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
  List<Group>? groupsRequests;
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    final requests = await DatabaseService.getUserGroupRequests(widget.uuid);
    setState(() {
      groupsRequests = requests;
    });
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
              child: ListView.builder(
                  itemCount: groupsRequests!.length,
                  itemBuilder: (context, index) {
                    return UserGroupRequestTile(
                        group: groupsRequests![index], uuid: widget.uuid);
                  }),
            ),
          );
  }
}
