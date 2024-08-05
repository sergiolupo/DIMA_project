import 'package:dima_project/models/group.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupsRequestsPage extends ConsumerStatefulWidget {
  final List<Group> groupRequests;
  const GroupsRequestsPage({super.key, required this.groupRequests});
  @override
  GroupsRequestsPageState createState() => GroupsRequestsPageState();
}

class GroupsRequestsPageState extends ConsumerState<GroupsRequestsPage> {
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
        middle: const Text('Group Requests'),
        leading: CupertinoButton(
          onPressed: () => Navigator.of(context).pop(),
          padding: const EdgeInsets.only(left: 10),
          child: const Icon(CupertinoIcons.back),
        ),
      ),
      child: SafeArea(
        child: ListView.builder(
            itemCount: groupsRequests.length,
            itemBuilder: (context, index) {
              final group = groupsRequests[index];
              return Row(
                children: [
                  Expanded(
                    child: CupertinoListTile(
                      leading:
                          CreateImageWidget.getGroupImage(group.imagePath!),
                      title: Text(
                        group.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
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
                        setState(() {
                          groupsRequests.removeAt(index);
                        });
                        ref.invalidate(groupsProvider(uid));
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
                        await databaseService.denyUserGroupRequest(
                            group.id, uid);
                        setState(() {
                          groupsRequests.removeAt(index);
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
            }),
      ),
    );
  }
}
