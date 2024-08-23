import 'package:dima_project/models/group.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserGroupsRequestsPage extends ConsumerStatefulWidget {
  final List<Group> groupRequests;
  const UserGroupsRequestsPage({super.key, required this.groupRequests});
  @override
  UserGroupsRequestsPageState createState() => UserGroupsRequestsPageState();
}

class UserGroupsRequestsPageState
    extends ConsumerState<UserGroupsRequestsPage> {
  late List<Group> groupsRequests;
  final String uid = AuthService.uid;
  @override
  void initState() {
    groupsRequests = widget.groupRequests;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final DatabaseService databaseService = ref.watch(databaseServiceProvider);
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text('Group Requests',
            style: TextStyle(color: CupertinoTheme.of(context).primaryColor)),
        leading: CupertinoButton(
          onPressed: () => Navigator.of(context).pop(),
          padding: const EdgeInsets.only(left: 10),
          child: const Icon(CupertinoIcons.back),
        ),
      ),
      child: groupsRequests.isEmpty
          ? Center(
              child: Column(
                children: [
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.width > Constants.limitWidth
                            ? 600
                            : 400,
                    child:
                        CupertinoTheme.of(context).brightness == Brightness.dark
                            ? Image.asset(
                                "assets/darkMode/no_group_requests.png",
                                fit: BoxFit.contain,
                              )
                            : Image.asset(
                                "assets/images/no_group_requests.png",
                                fit: BoxFit.contain,
                              ),
                  ),
                  const Text("No group requests",
                      style: TextStyle(
                          color: CupertinoColors.systemGrey2,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ],
              ),
            )
          : SafeArea(
              child: ListView.builder(
                  itemCount: groupsRequests.length,
                  itemBuilder: (context, index) {
                    final group = groupsRequests[index];
                    return Row(
                      children: [
                        Expanded(
                          child: CupertinoListTile(
                            leading: CreateImageWidget.getGroupImage(
                                group.imagePath!),
                            title: Text(
                              group.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("Description: ${group.description}",
                                maxLines: 1, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            try {
                              await databaseService.acceptUserGroupRequest(
                                group.id,
                              );
                              ref.invalidate(groupsProvider(uid));
                            } catch (e) {
                              if (!context.mounted) return;
                              showCupertinoDialog(
                                  context: context,
                                  builder: (context) {
                                    return CupertinoAlertDialog(
                                      title: const Text("Error"),
                                      content:
                                          const Text("Group has been deleted"),
                                      actions: [
                                        CupertinoDialogAction(
                                          child: const Text("Ok"),
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                        ),
                                      ],
                                    );
                                  });
                            }
                            setState(() {
                              groupsRequests.removeAt(index);
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
                                "Accept",
                                style: TextStyle(color: CupertinoColors.white),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () async {
                            await databaseService
                                .denyUserGroupRequest(group.id);
                            setState(() {
                              groupsRequests.removeAt(index);
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
                  }),
            ),
    );
  }
}
