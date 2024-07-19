import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/group_request_tile.dart';
import 'package:flutter/cupertino.dart';

class GroupRequestsPage extends StatefulWidget {
  final String groupId;

  const GroupRequestsPage({
    super.key,
    required this.groupId,
  });

  @override
  GroupRequestsPageState createState() => GroupRequestsPageState();
}

class GroupRequestsPageState extends State<GroupRequestsPage> {
  List<UserData>? users;
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    final requests =
        await DatabaseService.getGroupRequestsForGroup(widget.groupId);
    setState(() {
      users = requests;
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
        middle: const Text('Group Requests'),
      ),
      child: ListView.builder(
        itemCount: users!.length,
        itemBuilder: (context, index) {
          return GroupRequestTile(
            user: users![index],
            groupId: widget.groupId,
          );
        },
      ),
    );
  }
}
