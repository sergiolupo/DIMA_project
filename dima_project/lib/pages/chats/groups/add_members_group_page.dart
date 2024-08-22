import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/add_member_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AddMembersGroupPage extends ConsumerStatefulWidget {
  final Group group;
  @override
  const AddMembersGroupPage({
    super.key,
    required this.group,
  });

  @override
  AddMembersGroupPageState createState() => AddMembersGroupPageState();
}

class AddMembersGroupPageState extends ConsumerState<AddMembersGroupPage> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  final String uid = AuthService.uid;
  final List<String> uids = [];
  @override
  void initState() {
    ref.read(followerProvider(uid));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = ref.watch(databaseServiceProvider);
    final AsyncValue<List<UserData>> asyncUsers =
        ref.watch(followerProvider(uid));
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Navigator.canPop(context)
            ? CupertinoNavigationBarBackButton(
                color: CupertinoTheme.of(context).primaryColor,
                onPressed: () {
                  ref.invalidate(groupProvider(widget.group.id));
                  ref.invalidate(userProvider(uid));
                  Navigator.of(context).pop();
                },
              )
            : null,
        middle: Text(
          "Add Members",
          style: TextStyle(
            fontSize: 18,
            color: CupertinoTheme.of(context).primaryColor,
          ),
        ),
        trailing: Visibility(
          visible: uids.isNotEmpty,
          child: CupertinoButton(
            padding: const EdgeInsets.all(0),
            borderRadius: BorderRadius.circular(10),
            child: const Icon(CupertinoIcons.paperplane),
            onPressed: () async {
              BuildContext buildContext = context;
              showCupertinoDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext newContext) {
                  buildContext = newContext;
                  return const CupertinoAlertDialog(
                    content: CupertinoActivityIndicator(),
                  );
                },
              );
              await databaseService.inviteUserToGroup(
                  widget.group.id, uids, widget.group.members!);
              if (buildContext.mounted) {
                Navigator.of(buildContext).pop();
              }
              if (!context.mounted) return;
              Navigator.of(context).pop();
            },
          ),
        ),
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CupertinoSearchTextField(
              controller: _searchController,
              placeholder: "Search followers...",
              onChanged: (_) {
                setState(() {
                  searchText = _searchController.text;
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          asyncUsers.when(
            loading: () => const CupertinoActivityIndicator(),
            error: (err, stack) => Text('Error: $err'),
            data: (followers) {
              if (followers.isEmpty) {
                return SingleChildScrollView(
                  reverse: false,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Center(
                    child: Column(
                      children: [
                        MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? Image.asset(
                                'assets/darkMode/search_followers.png')
                            : Image.asset('assets/images/search_followers.png'),
                        const Text(
                          'No followers',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: CupertinoColors.systemGrey2),
                        ),
                      ],
                    ),
                  ),
                );
              }
              final filteredUsers = followers.where((user) {
                return user.username
                    .toLowerCase()
                    .contains(_searchController.text.toLowerCase());
              }).toList();

              if (filteredUsers.isEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? Image.asset('assets/darkMode/no_followers.png')
                        : Image.asset('assets/images/no_followers.png'),
                    const Center(
                      child: Text(
                        'No followers found',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: CupertinoColors.systemGrey2),
                      ),
                    ),
                  ],
                );
              }
              return Container(
                height: filteredUsers.length * 50.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: CupertinoTheme.of(context).primaryContrastingColor),
                child: ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final userData = filteredUsers[index];

                    return Column(
                      children: [
                        AddMemberTile(
                          user: userData,
                          onSelected: (String uuid) {
                            setState(() {
                              if (uids.contains(uuid)) {
                                uids.remove(uuid);
                              } else {
                                uids.add(uuid);
                              }
                            });
                          },
                          active: uids.contains(userData.uid!),
                          isJoining: userData.groups!.contains(widget.group.id),
                        ),
                        if (index != filteredUsers.length - 1)
                          Container(
                            height: 1,
                            color: CupertinoColors.opaqueSeparator
                                .withOpacity(0.2),
                          ),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
