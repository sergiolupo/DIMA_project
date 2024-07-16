import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/user_tile.dart';
import 'package:flutter/cupertino.dart';

class ShowEventMembersPage extends StatefulWidget {
  final String eventId;
  final String uuid;
  final String detailId;
  const ShowEventMembersPage({
    super.key,
    required this.eventId,
    required this.uuid,
    required this.detailId,
  });

  @override
  ShowEventMembersPageState createState() => ShowEventMembersPageState();
}

class ShowEventMembersPageState extends State<ShowEventMembersPage> {
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _membersStreamSubscription;
  late final StreamController<DocumentSnapshot<Map<String, dynamic>>>
      _membersStreamController =
      StreamController<DocumentSnapshot<Map<String, dynamic>>>();
  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    _membersStreamSubscription =
        DatabaseService.getMembersStreamUser(widget.eventId, widget.detailId)
            .listen((snapshot) {
      _membersStreamController.add(snapshot);
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
        middle: const Text('Members'),
      ),
      child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: _membersStreamController.stream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.data() == null) {
            return const CupertinoActivityIndicator();
          }
          if (snapshot.data!.data()!["members"].length == 0) {
            return const Center(
              child: Text('No members'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.data()!["members"].length,
            itemBuilder: (context, index) {
              final members = snapshot.data!.data()!["members"];

              if (members.isEmpty) {
                return const Center(
                  child: Text('No members'),
                );
              }

              final String uid = members[index].toString();

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
    );
  }

  @override
  void dispose() {
    _membersStreamSubscription?.cancel();
    _membersStreamController.close();
    super.dispose();
  }
}
