import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FollowRequestsPage extends ConsumerStatefulWidget {
  final List<UserData> followRequests;
  const FollowRequestsPage({super.key, required this.followRequests});
  @override
  FollowRequestsPageState createState() => FollowRequestsPageState();
}

class FollowRequestsPageState extends ConsumerState<FollowRequestsPage> {
  final String uid = AuthService.uid;
  late List<UserData> followRequests;
  @override
  void initState() {
    followRequests = widget.followRequests;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = ref.watch(databaseServiceProvider);
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
                        child:
                            CreateImageWidget.getUserImage(user.imagePath!, 1),
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
                    await databaseService.acceptUserRequest(
                      user.uid!,
                    );
                    setState(() {
                      followRequests.removeAt(index);
                    });
                    ref.invalidate(followerProvider(uid));
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
                    await databaseService.denyUserRequest(
                      user.uid!,
                    );
                    setState(() {
                      followRequests.removeAt(index);
                    });
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
