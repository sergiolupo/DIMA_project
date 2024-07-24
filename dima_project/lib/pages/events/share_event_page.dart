import 'package:dima_project/models/group.dart';
import 'package:dima_project/pages/news/share_news_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:flutter/cupertino.dart';

class ShareEventPage extends StatefulWidget {
  final List<String> groupIds;
  @override
  const ShareEventPage({super.key, required this.groupIds});

  @override
  State<ShareEventPage> createState() => ShareEventPageState();
}

class ShareEventPageState extends State<ShareEventPage> {
  List<String> groupsIds = [];

  List<Group>? groups;

  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  void fetchGroups() async {
    final List<Group> userGroups =
        await DatabaseService.getGroups(AuthService.uid);
    setState(() {
      groups = userGroups;
      groupsIds = widget.groupIds;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoTheme.of(context).primaryColor,
          onPressed: () {
            Navigator.of(context).pop(groupsIds);
          },
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(
            top: 16.0,
          ),
          child: getGroups(),
        ),
      ),
    );
  }

  Widget getGroups() {
    if (groups == null) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (groups!.isEmpty) {
      return const Center(
        child: Text("No groups"),
      );
    }
    return ListView.builder(
      itemCount: groups!.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return ShareGroupTile(
          group: groups![index],
          onSelected: (String id) {
            setState(() {
              if (groupsIds.contains(id)) {
                groupsIds.remove(id);
              } else {
                groupsIds.add(id);
              }
            });
          },
          active: groupsIds.contains(groups![index].id),
        );
      },
    );
  }
}
