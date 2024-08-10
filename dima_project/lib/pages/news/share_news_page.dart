import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/custom_selection_option_widget.dart';
import 'package:dima_project/widgets/news/share_group_tile.dart';
import 'package:dima_project/widgets/news/share_user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class ShareNewsPage extends StatefulWidget {
  final DatabaseService databaseService;
  @override
  const ShareNewsPage({
    super.key,
    required this.databaseService,
  });

  @override
  State<ShareNewsPage> createState() => ShareNewsPageState();
}

class ShareNewsPageState extends State<ShareNewsPage> {
  List<String> uuids = [];
  List<String> groupsIds = [];
  int index = 0;
  List<Group>? groups;
  List<UserData>? users;
  String _searchText = "";
  final String uid = AuthService.uid;
  @override
  void initState() {
    super.initState();
    fetchGroups();
    fetchUsers();
  }

  void fetchGroups() async {
    groups = await widget.databaseService.getGroups(uid);
    setState(() {});
  }

  void fetchUsers() async {
    final doc = await widget.databaseService.getFollowersUser(uid);
    if (doc.exists &&
        doc.data() != null &&
        (doc.data() as Map<String, dynamic>)['followers'] != null) {
      final followers =
          List<String>.from((doc.data() as Map<String, dynamic>)['followers']);
      users = await Future.wait(followers
          .map((uuid) => widget.databaseService.getUserData(uuid))
          .toList());
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Send To',
            style: TextStyle(color: CupertinoTheme.of(context).primaryColor)),
        leading: CupertinoButton(
          padding: const EdgeInsets.all(0),
          child: Text(
            'Cancel',
            style: TextStyle(color: CupertinoTheme.of(context).primaryColor),
          ),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        trailing: Visibility(
          visible: uuids.isNotEmpty || groupsIds.isNotEmpty,
          child: CupertinoButton(
            padding: const EdgeInsets.all(0),
            color: CupertinoTheme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(40),
            child: const Icon(LineAwesomeIcons.paper_plane),
            onPressed: () {
              dynamic map = {
                "users": uuids,
                "groups": groupsIds,
              };
              Navigator.of(context).pop(map);
            },
          ),
        ),
      ),
      child: SingleChildScrollView(
        reverse: false,
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CupertinoSearchTextField(
                    onChanged: (value) {
                      setState(() {
                        _searchText = value;
                      });
                    },
                  ),
                ),
                CustomSelectionOption(
                  textLeft: "Groups",
                  textRight: "Followers",
                  onChanged: (value) {
                    setState(() {
                      index = value;
                    });
                  },
                ),
                if (index == 0) getGroups(),
                if (index == 1) getUsers(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getUsers() {
    int i = 0;
    if (users == null) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (users!.isEmpty) {
      return Center(
        child: Column(
          children: [
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Image.asset('assets/darkMode/search_followers.png')
                : Image.asset('assets/images/search_followers.png'),
            const Text("No followers"),
          ],
        ),
      );
    }
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      itemCount: users!.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (!users![index]
            .username
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          i += 1;
          if (i == users!.length) {
            return Center(
              child: Column(
                children: [
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Image.asset('assets/darkMode/no_followers_found.png')
                      : Image.asset('assets/images/no_followers_found.png'),
                  const Text("No followers found"),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }
        return ShareUserTile(
          user: users![index],
          onSelected: (String uuid) {
            setState(() {
              if (uuids.contains(uuid)) {
                uuids.remove(uuid);
              } else {
                uuids.add(uuid);
              }
            });
          },
          active: uuids.contains(users![index].uid!),
        );
      },
    );
  }

  Widget getGroups() {
    int i = 0;
    if (groups == null) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (groups!.isEmpty) {
      return Center(
        child: Column(
          children: [
            MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Image.asset('assets/darkMode/search_groups.png')
                : Image.asset('assets/images/search_groups.png'),
            const Text("No groups"),
          ],
        ),
      );
    }
    return ListView.builder(
      physics: const ClampingScrollPhysics(),
      itemCount: groups!.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (!groups![index]
            .name
            .toLowerCase()
            .contains(_searchText.toLowerCase())) {
          i += 1;
          if (i == groups!.length) {
            return Center(
              child: Column(
                children: [
                  MediaQuery.of(context).platformBrightness == Brightness.dark
                      ? Image.asset('assets/darkMode/no_groups_found.png')
                      : Image.asset('assets/images/no_groups_found.png'),
                  const Text("No groups found"),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        }
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
