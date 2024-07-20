import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FollowRequestsPage extends ConsumerStatefulWidget {
  final String uuid;
  final List<UserData> followRequests;
  const FollowRequestsPage(
      {super.key, required this.uuid, required this.followRequests});
  @override
  FollowRequestsPageState createState() => FollowRequestsPageState();
}

class FollowRequestsPageState extends ConsumerState<FollowRequestsPage> {
  late List<UserData> followRequests;
  @override
  void initState() {
    followRequests = widget.followRequests;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
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
          itemCount: followRequests.length,
          itemBuilder: (context, index) {
            final user = followRequests[index];
            return Row(
              children: [
                Expanded(
                  child: CupertinoListTile(
                    leading: ClipOval(
                      child: Container(
                        width: 100,
                        height: 100,
                        color: CupertinoColors.lightBackgroundGray,
                        child: CreateImageWidget.getUserImage(user.imagePath!),
                      ),
                    ),
                    title: Text(
                      user.username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text("${user.name} ${user.surname}"),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      await DatabaseService.acceptUserRequest(
                          user.uuid!, widget.uuid);
                      setState(() {
                        followRequests.removeAt(index);
                      });
                      ref.invalidate(followerProvider(widget.uuid));
                    } catch (error) {
                      debugPrint("Error occurred: $error");
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoTheme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: const Text(
                        "Accept",
                        style: TextStyle(color: CupertinoColors.white),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    try {
                      await DatabaseService.denyUserRequest(
                          user.uuid!, widget.uuid);
                      setState(() {
                        followRequests.removeAt(index);
                      });
                    } catch (error) {
                      debugPrint("Error occurred: $error");
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: CupertinoTheme.of(context).primaryColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      child: const Text(
                        "Deny",
                        style: TextStyle(color: CupertinoColors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
