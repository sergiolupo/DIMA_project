import 'package:dima_project/models/group.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/group_invitation_tile.dart';
import 'package:flutter/cupertino.dart';

class ShareEventGroupPage extends StatefulWidget {
  final List<String> groupIds;
  final DatabaseService databaseService;
  @override
  const ShareEventGroupPage(
      {super.key, required this.groupIds, required this.databaseService});

  @override
  State<ShareEventGroupPage> createState() => ShareEventGroupPageState();
}

class ShareEventGroupPageState extends State<ShareEventGroupPage> {
  List<String> groupsIds = [];

  List<Group>? groups;
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  @override
  void initState() {
    super.initState();
    fetchGroups();
  }

  void fetchGroups() async {
    final List<Group> userGroups =
        await widget.databaseService.getGroups(AuthService.uid);
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: CupertinoSearchTextField(
                  controller: _searchController,
                  placeholder: "Search groups...",
                  onChanged: (_) {
                    setState(() {
                      searchText = _searchController.text;
                    });
                  },
                ),
              ),
              getGroups(),
            ],
          ),
        ),
      ),
    );
  }

  Widget getGroups() {
    if (groups == null) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (groups!.isEmpty) {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Image.asset('assets/darkMode/search_groups.png')
                : Image.asset('assets/images/search_groups.png'),
            const Center(
              child: Text('No groups'),
            ),
          ],
        ),
      );
    }
    final List<Group> filteredGroups = groups!
        .where((group) =>
            group.name.toLowerCase().contains(searchText.toLowerCase()))
        .toList();
    if (filteredGroups.isEmpty) {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          children: [
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Image.asset('assets/darkMode/no_groups_found.png')
                : Image.asset('assets/images/no_groups_found.png'),
            const Center(
              child: Text('No groups found'),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: CupertinoTheme.of(context).primaryContrastingColor),
      child: ListView.builder(
        itemCount: filteredGroups.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final group = filteredGroups[index];
          return GroupInvitationTile(
            group: group,
            onSelected: (String id) {
              setState(() {
                if (groupsIds.contains(id)) {
                  groupsIds.remove(id);
                } else {
                  groupsIds.add(id);
                }
              });
            },
            invited: groupsIds.contains(groups![index].id),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
