import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/groups/group_info_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class GroupRequestsPage extends StatefulWidget {
  final Group group;
  final List<UserData> requests;
  final bool canNavigate;
  final Function? navigateToPage;
  const GroupRequestsPage({
    super.key,
    required this.group,
    required this.requests,
    required this.canNavigate,
    this.navigateToPage,
  });

  @override
  GroupRequestsPageState createState() => GroupRequestsPageState();
}

class GroupRequestsPageState extends State<GroupRequestsPage> {
  late List<UserData> users;
  @override
  void initState() {
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
          onPressed: () {
            if (widget.canNavigate) {
              widget.navigateToPage!(GroupInfoPage(
                  group: widget.group,
                  canNavigate: widget.canNavigate,
                  navigateToPage: widget.navigateToPage));
            }
            Navigator.of(context).pop();
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
                    await DatabaseService.acceptGroupRequest(
                        widget.group.id, user.uid!);
                    setState(() {
                      users.removeAt(index);
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
                      border: Border.all(color: CupertinoColors.white),
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
                  try {
                    await DatabaseService.denyGroupRequest(
                        widget.group.id, user.uid!);
                    setState(() {
                      users.removeAt(index);
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
                      border: Border.all(color: CupertinoColors.white),
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
