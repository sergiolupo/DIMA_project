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
  late Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _followerStream;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() {
    _followerStream = DatabaseService.getFollowersStream(widget.user.username);
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: widget.followers
            ? const Text('Followers')
            : const Text('Following'),
      ),
      child: StreamBuilder<List<DocumentSnapshot<Map<String, dynamic>>>>(
        stream: _followerStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          final docs = snapshot.data ?? [];
          if (docs.isEmpty) {
            return Center(
              child: widget.followers
                  ? const Text('No followers')
                  : const Text('Not following anyone'),
            );
          }
          return ListView.builder(
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final followers = docs[index]['followers'] as List<dynamic>;
              final following = docs[index]['following'] as List<dynamic>;

              final List<dynamic> usernames =
                  widget.followers ? followers : following;

              if (usernames.isEmpty) {
                return Center(
                  child: widget.followers
                      ? const Text('No followers')
                      : const Text('Not following anyone'),
                );
              }

              final String username = usernames.first.toString();

              debugPrint('username: $username');
              return FutureBuilder<UserData>(
                future: DatabaseService.getUserDataFromUsername(
                    username.toString()),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CupertinoActivityIndicator(); // Or any loading indicator
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else {
                    final searchedUser = snapshot.data!;
                    return UserTile(
                      user: searchedUser,
                      visitor: widget.visitor ?? widget.user,
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
