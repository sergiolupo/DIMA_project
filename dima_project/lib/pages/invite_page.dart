import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/invitation_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvitePage extends ConsumerStatefulWidget {
  final ValueChanged<String> invitePageKey;
  final List<String> invitedUsers;
  final bool isGroup;
  final String? id;
  @override
  const InvitePage({
    super.key,
    required this.invitePageKey,
    required this.invitedUsers,
    required this.isGroup,
    required this.id,
  });

  @override
  InvitePageState createState() => InvitePageState();
}

class InvitePageState extends ConsumerState<InvitePage> {
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  final String uid = AuthService.uid;
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
          Expanded(
            child: asyncUsers.when(
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
                              : Image.asset(
                                  'assets/images/search_followers.png'),
                          const Text('No followers'),
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
                      MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Image.asset('assets/darkMode/no_followers.png')
                          : Image.asset('assets/images/no_followers.png'),
                      const Center(
                        child: Text('No followers found'),
                      ),
                    ],
                  );
                }
                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final userData = filteredUsers[index];
                    return FutureBuilder(
                      future: databaseService.checkIfJoined(
                          widget.isGroup, widget.id, userData.uid!),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return const Text('Error');
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Text('Loading');
                        }
                        final isJoining = snapshot.data as bool;

                        return InvitationTile(
                          user: userData,
                          invitePageKey: widget.invitePageKey,
                          invited: widget.invitedUsers.contains(userData.uid),
                          isJoining: isJoining,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
