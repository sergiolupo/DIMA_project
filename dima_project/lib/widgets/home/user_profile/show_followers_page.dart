import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ShowFollowers extends StatefulWidget {
  final String user;
  final String uuid;
  final bool followers;
  const ShowFollowers({
    super.key,
    required this.user,
    required this.uuid,
    required this.followers,
  });

  @override
  ShowFollowersState createState() => ShowFollowersState();
}

class ShowFollowersState extends State<ShowFollowers> {
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _followersStreamSubscription;
  late final StreamController<DocumentSnapshot<Map<String, dynamic>>>
      _followersStreamController =
      StreamController<DocumentSnapshot<Map<String, dynamic>>>();
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    _followersStreamSubscription =
        DatabaseService.getFollowersStreamUser(widget.user).listen((snapshot) {
      _followersStreamController.add(snapshot);
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
        middle: widget.followers
            ? const Text('Followers')
            : const Text('Following'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: CupertinoSearchTextField(
                controller: _searchController,
                onChanged: (_) => (setState(() {
                  _searchText = _searchController.text;
                })),
              ),
            ),
            StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _followersStreamController.stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.data() == null) {
                  return const CupertinoActivityIndicator();
                }
                if (widget.followers &&
                    snapshot.data!.data()!["followers"].length == 0) {
                  return Column(
                    children: [
                      Image.asset('assets/images/no_followers_found.png'),
                      const Center(
                        child: Text('No followers'),
                      ),
                    ],
                  );
                }
                if (!widget.followers &&
                    snapshot.data!.data()!["following"].length == 0) {
                  return Column(
                    children: [
                      Image.asset('assets/images/no_following_found.png'),
                      const Center(
                        child: Text('Not following anyone'),
                      ),
                    ],
                  );
                }
                int i = 0;
                final docs = widget.followers
                    ? snapshot.data!.data()!["followers"]
                    : snapshot.data!.data()!["following"];
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final List<dynamic> uuids = docs;

                    if (uuids.isEmpty) {
                      return Center(
                        child: widget.followers
                            ? Column(
                                children: [
                                  Image.asset(
                                      'assets/images/search_followers.png'),
                                  const Text('No followers'),
                                ],
                              )
                            : Column(
                                children: [
                                  Image.asset(
                                      'assets/images/search_following.png'),
                                  const Text('Not following anyone'),
                                ],
                              ),
                      );
                    }

                    final String uid = uuids[index].toString();

                    return StreamBuilder<UserData>(
                      stream:
                          DatabaseService.getUserDataFromUUID(uid.toString()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CupertinoActivityIndicator(); // Or any loading indicator
                        } else if (snapshot.hasError) {
                          return Text('Error: ${snapshot.error}');
                        } else {
                          final UserData userData = snapshot.data!;
                          if (!userData.username
                              .toLowerCase()
                              .contains(_searchText.toLowerCase())) {
                            i += 1;
                            if (i == docs.length) {
                              return Center(
                                child: widget.followers
                                    ? Column(
                                        children: [
                                          Image.asset(
                                              'assets/images/search_followers.png'),
                                          const Text('No followers'),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          Image.asset(
                                              'assets/images/search_following.png'),
                                          const Text('Not following anyone'),
                                        ],
                                      ),
                              );
                            }
                            return const SizedBox.shrink();
                          }

                          return StreamBuilder(
                              stream: DatabaseService.isFollowing(
                                  userData.uuid!, widget.uuid),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const CupertinoActivityIndicator();
                                } else if (snapshot.hasError) {
                                  return Text('Error: ${snapshot.error}');
                                } else {
                                  final isFollowing = snapshot.data as int;
                                  return UserTile(
                                    user: userData,
                                    uuid: widget.uuid,
                                    isFollowing: isFollowing,
                                  );
                                }
                              });
                        }
                      },
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _followersStreamSubscription?.cancel();
    _followersStreamController.close();
    super.dispose();
  }
}
