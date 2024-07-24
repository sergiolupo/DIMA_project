import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class GroupRequestsPage extends StatefulWidget {
  final String groupId;
  final List<UserData> requests;

  const GroupRequestsPage({
    super.key,
    required this.groupId,
    required this.requests,
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
                        widget.groupId, user.uid!);
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
                        widget.groupId, user.uid!);
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
