import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/selectoption_widget.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class ShareNewsPage extends StatefulWidget {
  final String uuid;
  @override
  const ShareNewsPage({super.key, required this.uuid});

  @override
  State<ShareNewsPage> createState() => ShareNewsPageState();
}

class ShareNewsPageState extends State<ShareNewsPage> {
  List<String> uuids = [];
  List<String> groupsIds = [];
  int index = 0;
  List<Group>? groups;
  List<UserData>? users;
  @override
  void initState() {
    super.initState();
    fetchGroups();
    fetchUsers();
  }

  void fetchGroups() async {
    groups = await DatabaseService.getGroups(widget.uuid);
    setState(() {});
  }

  void fetchUsers() async {
    final doc = await DatabaseService.getFollowersUser(widget.uuid);
    if (doc.exists && doc.data() != null && doc.data()!['followers'] != null) {
      final followers = List<String>.from(doc.data()!['followers']);
      users = await Future.wait(
          followers.map((uuid) => DatabaseService.getUserData(uuid)).toList());
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoColors.systemPink,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      child: SafeArea(
        child: Stack(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomSelectOption(
                  textLeft: "Groups",
                  textRight: "Private",
                  onChanged: (value) {
                    setState(() {
                      index = value;
                    });
                  },
                ),
                if (index == 0) getGroups(),
                if (index == 1) getUsers(),
              ],
            ),
            Visibility(
              visible: uuids.isNotEmpty || groupsIds.isNotEmpty,
              child: SafeArea(
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: CupertinoButton(
                    child: const Icon(CupertinoIcons.paperplane),
                    onPressed: () {
                      dynamic map = {
                        "users": uuids,
                        "groups": groupsIds,
                      };
                      Navigator.of(context).pop(map);
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getUsers() {
    if (users == null) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (users!.isEmpty) {
      return const Center(
        child: Text("No followers"),
      );
    }
    return ListView.builder(
      itemCount: users!.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return ShareUserTile(
          user: users![index],
          onSelected: (String uuid) {
            setState(() {
              if (uuids.contains(uuid)) {
                uuids.remove(uuid);
              } else {
                uuids.add(uuid);
              }
            });
          },
          active: uuids.contains(users![index].uuid!),
        );
      },
    );
  }

  Widget getGroups() {
    if (groups == null) {
      return const Center(child: CupertinoActivityIndicator());
    }
    if (groups!.isEmpty) {
      return const Center(
        child: Text("No groups"),
      );
    }
    return ListView.builder(
      itemCount: groups!.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return ShareGroupTile(
          group: groups![index],
          onSelected: (String id) {
            setState(() {
              if (groupsIds.contains(id)) {
                groupsIds.remove(id);
              } else {
                groupsIds.add(id);
              }
            });
          },
          active: groupsIds.contains(groups![index].id),
        );
      },
    );
  }
}

class ShareGroupTile extends StatefulWidget {
  final Group group;
  final ValueChanged<String> onSelected;
  final bool active;
  @override
  const ShareGroupTile({
    super.key,
    required this.group,
    required this.onSelected,
    required this.active,
  });

  @override
  State<ShareGroupTile> createState() => ShareGroupTileState();
}

class ShareGroupTileState extends State<ShareGroupTile> {
  bool isActive = false;

  @override
  void initState() {
    setState(() {
      isActive = widget.active;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: isActive ? CupertinoColors.activeGreen : CupertinoColors.white,
        child: CupertinoListTile(
          leading: Stack(
            children: [
              ClipOval(
                child: Container(
                  width: 100,
                  height: 100,
                  color: CupertinoColors.lightBackgroundGray,
                  child:
                      CreateImageWidget.getGroupImage(widget.group.imagePath!),
                ),
              ),
              if (isActive)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: CupertinoColors.activeGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark,
                      color: CupertinoColors.white,
                      size: 8,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            widget.group.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(widget.group.description!),
        ),
      ),
      onTap: () {
        setState(() {
          isActive = !isActive;
        });
        widget.onSelected(widget.group.id);
      },
    );
  }
}

class ShareUserTile extends StatefulWidget {
  final UserData user;
  final ValueChanged<String> onSelected;
  final bool active;
  @override
  const ShareUserTile({
    super.key,
    required this.user,
    required this.onSelected,
    required this.active,
  });

  @override
  State<ShareUserTile> createState() => ShareUserTileState();
}

class ShareUserTileState extends State<ShareUserTile> {
  bool isActive = false;

  @override
  void initState() {
    setState(() {
      isActive = widget.active;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        color: isActive ? CupertinoColors.activeGreen : CupertinoColors.white,
        child: CupertinoListTile(
          leading: Stack(
            children: [
              ClipOval(
                child: Container(
                  width: 100,
                  height: 100,
                  color: CupertinoColors.lightBackgroundGray,
                  child: CreateImageWidget.getUserImage(widget.user.imagePath!),
                ),
              ),
              if (isActive)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: CupertinoColors.activeGreen,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark,
                      color: CupertinoColors.white,
                      size: 8,
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            widget.user.username,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text("${widget.user.name} ${widget.user.surname}"),
        ),
      ),
      onTap: () {
        setState(() {
          isActive = !isActive;
        });
        widget.onSelected(widget.user.uuid!);
      },
    );
  }
}
