import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/user_tile.dart';
import 'package:flutter/cupertino.dart';

class ShowFollowers extends StatefulWidget {
  final UserData user;
  final UserData? visitor;
  final bool followers;
  const ShowFollowers({
    super.key,
    required this.user,
    this.visitor,
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
  @override
  void initState() {
    super.initState();
    init();
    debugPrint('visitor: ${widget.visitor?.username}');
    debugPrint('user: ${widget.user.username}');
  }

  init() {
    _followersStreamSubscription =
        DatabaseService.getFollowersStreamUser(widget.user.uuid!)
            .listen((snapshot) {
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
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
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
            return const Center(
              child: Text('No followers'),
            );
          }
          if (!widget.followers &&
              snapshot.data!.data()!["following"].length == 0) {
            return const Center(
              child: Text('Not following anyone'),
            );
          }
          return ListView.builder(
            itemCount: widget.followers
                ? snapshot.data!.data()!["followers"].length
                : snapshot.data!.data()!["following"].length,
            itemBuilder: (context, index) {
              final followers = snapshot.data!.data()!["followers"];
              final following = snapshot.data!.data()!["following"];

              final List<dynamic> uuids =
                  widget.followers ? followers : following;

              if (uuids.isEmpty) {
                return Center(
                  child: widget.followers
                      ? const Text('No followers')
                      : const Text('Not following anyone'),
                );
              }

              final String uid = uuids[index].toString();

              return StreamBuilder<UserData>(
                stream: DatabaseService.getUserDataFromUUID(uid.toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CupertinoActivityIndicator(); // Or any loading indicator
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final UserData userData = snapshot.data!;
                    return StreamBuilder(
                        stream: DatabaseService.isFollowingUser(
                            userData.uuid!, widget.user.uuid!),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CupertinoActivityIndicator();
                          } else if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          } else {
                            final isFollowing = snapshot.data as bool;
                            return UserTile(
                              user: userData,
                              visitor: widget.user,
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
    );
  }

  @override
  void dispose() {
    _followersStreamSubscription?.cancel();
    _followersStreamController.close();
    super.dispose();
  }
}
