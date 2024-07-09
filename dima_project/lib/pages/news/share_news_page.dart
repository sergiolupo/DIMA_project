import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class ShareNewsPage extends StatefulWidget {
  final String blogUrl;
  final String uuid;
  @override
  const ShareNewsPage({super.key, required this.blogUrl, required this.uuid});

  @override
  State<ShareNewsPage> createState() => ShareNewsPageState();
}

class ShareNewsPageState extends State<ShareNewsPage> {
  List<String> uuids = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("AGOR"),
            Text("APP",
                style: TextStyle(
                    color: CupertinoColors.activeBlue,
                    fontWeight: FontWeight.bold))
          ],
        ),
      ),
      child: Stack(
        children: [
          StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            stream: DatabaseService.getFollowersStreamUser(widget.uuid),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CupertinoActivityIndicator());
              }
              if (snapshot.data!.data()!["followers"].isEmpty) {
                return const Center(
                  child: Text("No followers"),
                );
              }
              return ListView.builder(
                itemCount: snapshot.data!.data()!["followers"].length,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  return StreamBuilder(
                    stream: DatabaseService.getUserDataFromUUID(
                        snapshot.data!.data()!["followers"][index]),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CupertinoActivityIndicator());
                      }
                      return ShareUserTile(
                        user: snapshot.data!,
                        onSelected: (String uuid) {
                          setState(() {
                            if (uuids.contains(uuid)) {
                              uuids.remove(uuid);
                            } else {
                              uuids.add(uuid);
                            }
                          });
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
          //I want the container to be at the bottom of the screen

          Visibility(
            visible: uuids.isNotEmpty,
            child: SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: CupertinoButton(
                  child: const Icon(CupertinoIcons.paperplane),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShareUserTile extends StatefulWidget {
  final UserData user;
  final ValueChanged<String> onSelected;
  @override
  const ShareUserTile({
    super.key,
    required this.user,
    required this.onSelected,
  });

  @override
  State<ShareUserTile> createState() => ShareUserTileState();
}

class ShareUserTileState extends State<ShareUserTile> {
  bool isActive = false;

  @override
  void initState() {
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
