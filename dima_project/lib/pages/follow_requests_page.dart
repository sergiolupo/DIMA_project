import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/user_request_tile.dart';
import 'package:flutter/cupertino.dart';

class FollowRequestsPage extends StatefulWidget {
  final String uuid;
  const FollowRequestsPage({super.key, required this.uuid});
  @override
  FollowRequestsPageState createState() => FollowRequestsPageState();
}

class FollowRequestsPageState extends State<FollowRequestsPage> {
  List<UserData>? userRequests;
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    final requests =
        await DatabaseService.getFollowRequestsForUser(widget.uuid);
    setState(() {
      userRequests = requests;
    });
  }

  @override
  Widget build(BuildContext context) {
    return userRequests == null
        ? const Center(child: CupertinoActivityIndicator())
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: const Text('Requests'),
              leading: CupertinoButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: const EdgeInsets.only(left: 10),
                child: const Icon(CupertinoIcons.back),
              ),
            ),
            child: SafeArea(
              child: ListView.builder(
                itemCount: userRequests!.length,
                itemBuilder: (context, index) {
                  return UserRequestTile(
                      user: userRequests![index], uuid: widget.uuid);
                },
              ),
            ),
          );
  }
}
