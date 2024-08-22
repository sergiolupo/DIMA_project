import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/custom_selection_option_widget.dart';
import 'package:dima_project/widgets/share_group_tile.dart';
import 'package:dima_project/widgets/share_user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShareNewsPage extends ConsumerStatefulWidget {
  final DatabaseService databaseService;
  @override
  const ShareNewsPage({
    super.key,
    required this.databaseService,
  });

  @override
  ConsumerState<ShareNewsPage> createState() => ShareNewsPageState();
}

class ShareNewsPageState extends ConsumerState<ShareNewsPage> {
  List<String> uuids = [];
  List<String> groupsIds = [];
  int index = 0;
  List<Group>? groups;
  List<UserData>? users;
  String _searchText = "";
  final String uid = AuthService.uid;
  @override
  void initState() {
    ref.read(groupsProvider(uid));
    ref.read(followerProvider(uid));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final asyncGroups = ref.watch(groupsProvider(uid));
    final asyncUsers = ref.watch(followerProvider(uid));
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Padding(
          padding: const EdgeInsets.only(bottom: 4.0),
          child: Text('Send To',
              style: TextStyle(
                  color: CupertinoTheme.of(context).primaryColor,
                  fontSize: 20)),
        ),
        leading: CupertinoNavigationBarBackButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          color: CupertinoTheme.of(context).primaryColor,
        ),
        trailing: Visibility(
          visible: uuids.isNotEmpty || groupsIds.isNotEmpty,
          child: CupertinoButton(
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(10),
            child: const Icon(CupertinoIcons.paperplane),
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
                if (index == 0) getGroups(asyncGroups),
                if (index == 1) getUsers(asyncUsers),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget getUsers(AsyncValue<List<UserData>> asyncUsers) {
    int i = 0;
    return asyncUsers.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, stack) => const Center(child: Text('Error')),
        data: (users) {
          if (users.isEmpty) {
            return Column(
              children: [
                MediaQuery.of(context).platformBrightness == Brightness.dark
                    ? Image.asset('assets/darkMode/search_followers.png')
                    : Image.asset('assets/images/search_followers.png'),
                const Text(
                  "No followers",
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: CupertinoColors.systemGrey2),
                ),
              ],
            );
          }
          return Container(
            height: users.length * 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: CupertinoTheme.of(context).primaryContrastingColor),
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              itemCount: users.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (!users[index]
                    .username
                    .toLowerCase()
                    .contains(_searchText.toLowerCase())) {
                  i += 1;
                  if (i == users.length) {
                    return Column(
                      children: [
                        MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? Image.asset('assets/darkMode/no_followers.png')
                            : Image.asset('assets/images/no_followers.png'),
                        const Center(
                            child: Text(
                          "No followers found",
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.systemGrey2),
                        )),
                      ],
                    );
                  }
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    ShareUserTile(
                      user: users[index],
                      onSelected: (String uuid) {
                        setState(() {
                          if (uuids.contains(uuid)) {
                            uuids.remove(uuid);
                          } else {
                            uuids.add(uuid);
                          }
                        });
                      },
                      active: uuids.contains(users[index].uid!),
                    ),
                    if (index != users.length - 1)
                      Container(
                        height: 1,
                        color: CupertinoColors.opaqueSeparator.withOpacity(0.2),
                      ),
                  ],
                );
              },
            ),
          );
        });
  }

  Widget getGroups(AsyncValue<List<Group>> asyncGroups) {
    int i = 0;
    return asyncGroups.when(
        loading: () => const Center(child: CupertinoActivityIndicator()),
        error: (error, stack) => const Center(child: Text('Error')),
        data: (groups) {
          if (groups.isEmpty) {
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
          return Container(
            height: groups.length * 50,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: CupertinoTheme.of(context).primaryContrastingColor),
            child: ListView.builder(
              physics: const ClampingScrollPhysics(),
              itemCount: groups.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                if (!groups[index]
                    .name
                    .toLowerCase()
                    .contains(_searchText.toLowerCase())) {
                  i += 1;
                  if (i == groups.length) {
                    return Center(
                      child: Column(
                        children: [
                          MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Image.asset(
                                  'assets/darkMode/no_groups_found.png')
                              : Image.asset(
                                  'assets/images/no_groups_found.png'),
                          const Text("No groups found"),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }
                return Column(
                  children: [
                    ShareGroupTile(
                      group: groups[index],
                      onSelected: (String id) {
                        setState(() {
                          if (groupsIds.contains(id)) {
                            groupsIds.remove(id);
                          } else {
                            groupsIds.add(id);
                          }
                        });
                      },
                      active: groupsIds.contains(groups[index].id),
                    ),
                    if (index != groups.length - 1)
                      Container(
                        height: 1,
                        color: CupertinoColors.opaqueSeparator.withOpacity(0.2),
                      ),
                  ],
                );
              },
            ),
          );
        });
  }
}
