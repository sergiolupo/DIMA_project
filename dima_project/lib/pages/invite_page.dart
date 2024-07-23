import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/responsive_userprofile.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class InvitePage extends ConsumerStatefulWidget {
  final String uuid;
  final ValueChanged<String> invitePageKey;
  final List<String> invitedUsers;
  final bool isGroup;
  final String? id;
  @override
  const InvitePage({
    super.key,
    required this.uuid,
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

  @override
  void initState() {
    ref.read(followerProvider(widget.uuid));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<UserData>> asyncUsers =
        ref.watch(followerProvider(widget.uuid));
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
              placeholder: "Search followers ...",
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
                          ? Image.asset(
                              'assets/darkMode/no_followers_found.png')
                          : Image.asset('assets/images/no_followers_found.png'),
                      const Center(
                        child: Text('Not results found'),
                      ),
                    ],
                  );
                }
                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final userData = filteredUsers[index];
                    return FutureBuilder(
                      future: DatabaseService.checkIfJoined(
                          widget.isGroup, widget.id, userData.uuid!),
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
                          uuid: widget.uuid,
                          invitePageKey: widget.invitePageKey,
                          invited: widget.invitedUsers.contains(userData.uuid),
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

class InvitationTile extends StatefulWidget {
  final UserData user;
  final ValueChanged<String> invitePageKey;
  final String uuid;
  final bool invited;
  final bool isJoining;
  const InvitationTile({
    super.key,
    required this.user,
    required this.invitePageKey,
    required this.uuid,
    required this.invited,
    required this.isJoining,
  });

  @override
  InvitationTileState createState() => InvitationTileState();
}

class InvitationTileState extends State<InvitationTile> {
  bool invited = false;
  @override
  void initState() {
    invited = widget.invited;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return ResponsiveUserprofile(
                  user: widget.user.uuid!,
                  uuid: widget.uuid,
                );
              }));
            },
            child: CupertinoListTile(
              leading: ClipOval(
                child: Container(
                  width: 100,
                  height: 100,
                  color: CupertinoColors.lightBackgroundGray,
                  child: CreateImageWidget.getUserImage(widget.user.imagePath!),
                ),
              ),
              title: Text(
                widget.user.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${widget.user.name} ${widget.user.surname}"),
            ),
          ),
        ),
        widget.isJoining
            ? const SizedBox.shrink()
            : GestureDetector(
                onTap: () {
                  widget.invitePageKey(widget.user.uuid!);
                  setState(() {
                    invited = !invited;
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      invited ? 'Invited' : 'Invite',
                      style: const TextStyle(color: CupertinoColors.white),
                    ),
                  ),
                ),
              )
      ],
    );
  }
}
