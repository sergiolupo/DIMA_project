import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/userprofile_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class InvitePage extends StatefulWidget {
  final String uuid;
  final ValueChanged<String> invitePageKey;
  final List<String> invitedUsers;
  const InvitePage({
    super.key,
    required this.uuid,
    required this.invitePageKey,
    required this.invitedUsers,
  });

  @override
  InvitePageState createState() => InvitePageState();
}

class InvitePageState extends State<InvitePage> {
  final TextEditingController _searchController = TextEditingController();
  final StreamController<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _searchStreamController =
      StreamController<List<QueryDocumentSnapshot<Map<String, dynamic>>>>();

  StreamSubscription<List<QueryDocumentSnapshot<Map<String, dynamic>>>>?
      _searchStreamSubscription;

  @override
  void initState() {
    _initiateSearchMethod();
    super.initState();
  }

  void _initiateSearchMethod() {
    final searchText = _searchController.text.trim();
    _searchStreamSubscription?.cancel();

    _searchStreamSubscription =
        DatabaseService.searchByUsernameStream(searchText).listen((snapshot) {
      _searchStreamController.add(snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Navigator.canPop(context)
            ? CupertinoNavigationBarBackButton(
                color: CupertinoColors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : null,
        middle: const Text(
          "Invite Friends",
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.white,
          ),
        ),
        backgroundColor: CupertinoTheme.of(context).primaryColor,
      ),
      child: Column(
        children: [
          Container(
            color: CupertinoTheme.of(context).primaryColor,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: CupertinoTextField(
                    controller: _searchController,
                    onChanged: (_) => _initiateSearchMethod(),
                    placeholder: "Search followers ...",
                    placeholderStyle:
                        const TextStyle(color: CupertinoColors.white),
                    style: const TextStyle(color: CupertinoColors.white),
                    decoration: BoxDecoration(border: Border.all(width: 0)),
                  ),
                ),
                GestureDetector(
                  onTap: _initiateSearchMethod,
                  child: Container(
                    width: 40,
                    height: 40,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: CupertinoColors.white.withOpacity(1.0),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      CupertinoIcons.search,
                      color: CupertinoColors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<
                List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
              stream: _searchStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                final docs = snapshot.data ?? [];
                if (docs.isEmpty) {
                  return Center(
                    child: Text(
                        "No users found with the username ${_searchController.text}"),
                  );
                }

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    if (snapshot.hasData) {
                      final userData = UserData.fromSnapshot(docs[index]);
                      return StreamBuilder(
                          stream: DatabaseService.isFollowingUser(
                              widget.uuid, userData.uuid!),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return const Text('Error');
                            }
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Text('Loading');
                            }
                            final isFollowing = snapshot.data as bool;
                            if (!isFollowing) {
                              return const SizedBox.shrink();
                            }
                            return InvitationTile(
                              user: userData,
                              uuid: widget.uuid,
                              invitePageKey: widget.invitePageKey,
                              invited:
                                  widget.invitedUsers.contains(userData.uuid),
                            );
                          });
                    } else {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                            child: CupertinoActivityIndicator());
                      }
                      if (snapshot.data == null) {
                        return Center(
                          child: Text(
                              "No followers found with the username ${_searchController.text}"),
                        );
                      }
                    }
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
    _searchStreamController.close(); // Close the stream controller
    _searchStreamSubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }
}

class InvitationTile extends StatefulWidget {
  final UserData user;
  final ValueChanged<String> invitePageKey;
  final String uuid;
  final bool invited;
  const InvitationTile({
    super.key,
    required this.user,
    required this.invitePageKey,
    required this.uuid,
    required this.invited,
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
                return UserProfile(
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
        GestureDetector(
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
                border: Border.all(color: CupertinoColors.white),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
