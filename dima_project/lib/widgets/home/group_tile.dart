import 'package:dima_project/models/group.dart';
import 'package:dima_project/pages/groups/group_chat_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class GroupTile extends ConsumerWidget {
  final Group group;
  final int isJoined; // 0 is not joined, 1 is joined, 2 is requested

  const GroupTile({
    super.key,
    required this.group,
    required this.isJoined,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String uid = AuthService.uid;

    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              if (isJoined == 1) {
                Navigator.of(context, rootNavigator: true).push(
                  CupertinoPageRoute(
                    builder: (context) => GroupChatPage(
                      group: group,
                      canNavigate: false,
                    ),
                  ),
                );
              }
            },
            child: Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width > Constants.limitWidth
                      ? 8.0
                      : 0),
              child: CupertinoListTile(
                leading: Transform.scale(
                    scale:
                        MediaQuery.of(context).size.width > Constants.limitWidth
                            ? 1.3
                            : 1,
                    child: CreateImageWidget.getGroupImage(group.imagePath!)),
                title: Text(
                  group.name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: MediaQuery.of(context).size.width >
                              Constants.limitWidth
                          ? 20
                          : 17),
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: () async {
            try {
              await DatabaseService.toggleGroupJoin(group.id);
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                isJoined == 1
                    ? "Joined"
                    : isJoined == 2
                        ? "Requested"
                        : "Join",
                style: TextStyle(
                    color: CupertinoColors.white,
                    fontSize:
                        MediaQuery.of(context).size.width > Constants.limitWidth
                            ? 18
                            : 15),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
