import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/chats/groups/group_info_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class GroupRequestsPage extends StatefulWidget {
  final Group group;
  final List<UserData> requests;
  final bool canNavigate;
  final Function? navigateToPage;
  final DatabaseService databaseService;
  final NotificationService notificationService;

  const GroupRequestsPage({
    super.key,
    required this.group,
    required this.requests,
    required this.canNavigate,
    this.navigateToPage,
    required this.databaseService,
    required this.notificationService,
  });

  @override
  GroupRequestsPageState createState() => GroupRequestsPageState();
}

class GroupRequestsPageState extends State<GroupRequestsPage> {
  late List<UserData> users;
  late final DatabaseService _databaseService;

  @override
  void initState() {
    _databaseService = widget.databaseService;
    users = widget.requests;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () async {
            Group group =
                await _databaseService.getGroupFromId(widget.group.id);
            if (widget.canNavigate) {
              widget.navigateToPage!(GroupInfoPage(
                group: group,
                canNavigate: widget.canNavigate,
                navigateToPage: widget.navigateToPage,
                databaseService: _databaseService,
                notificationService: widget.notificationService,
                imagePicker: ImagePicker(),
              ));
              return;
            }
            if (!context.mounted) return;
            Navigator.of(context).pop(group);
          },
        ),
        middle: const Text('Group Requests'),
      ),
      child: ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          final UserData user = users[index];
          return Row(
            children: [
              Expanded(
                child: CupertinoListTile(
                  leading: ClipOval(
                    child: Container(
                      width: 100,
                      height: 100,
                      color: CupertinoColors.lightBackgroundGray,
                      child: CreateImageWidget.getUserImage(user.imagePath!, 1),
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
                    await _databaseService.acceptGroupRequest(
                        widget.group.id, user.uid!);
                  } catch (error) {
                    if (!context.mounted) return;
                    showCupertinoDialog(
                        context: context,
                        builder: (context) {
                          return CupertinoAlertDialog(
                            title: const Text("Error"),
                            content: const Text("User deleted his account"),
                            actions: [
                              CupertinoDialogAction(
                                child: const Text("Ok"),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          );
                        });
                  }
                  setState(() {
                    users.removeAt(index);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: const Text(
                      "Accept",
                      style: TextStyle(color: CupertinoColors.white),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await _databaseService.denyGroupRequest(
                      widget.group.id, user.uid!);
                  setState(() {
                    users.removeAt(index);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.only(right: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: CupertinoTheme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
    );
  }
}
