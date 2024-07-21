import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/userprofile_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserTile extends ConsumerStatefulWidget {
  final UserData user;
  final String uuid;
  final int? isFollowing; // 0 is not following, 1 is following, 2 is requested
  const UserTile({
    super.key,
    required this.user,
    required this.uuid,
    required this.isFollowing,
  });

  @override
  UserTileState createState() => UserTileState();
}

class UserTileState extends ConsumerState<UserTile> {
  @override
  void initState() {
    ref.read(userProvider(widget.user.uuid!));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              ref.invalidate(userProvider(widget.user.uuid!));
              ref.invalidate(followerProvider(widget.user.uuid!));
              ref.invalidate(followingProvider(widget.user.uuid!));
              ref.invalidate(groupsProvider(widget.user.uuid!));
              ref.invalidate(joinedEventsProvider(widget.user.uuid!));
              ref.invalidate(createdEventsProvider(widget.user.uuid!));
              ref.invalidate(eventProvider(widget.user.uuid!));
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return UserProfile(
                  user: widget.user.uuid!,
                  uuid: widget.uuid,
                );
              }));
            },
            child: CupertinoListTile(
              leading: ClipOval(
                child: Container(
                  width: 100,
                  height: 100,
                  color: CupertinoColors.lightBackgroundGray,
                  child: CreateImageWidget.getUserImage(widget.user.imagePath!),
                ),
              ),
              title: Text(
                widget.user.username,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text("${widget.user.name} ${widget.user.surname}"),
            ),
          ),
        ),
        widget.user.uuid != widget.uuid && widget.isFollowing != null
            ? GestureDetector(
                onTap: () async {
                  try {
                    await DatabaseService.toggleFollowUnfollow(
                      widget.user.uuid!,
                      widget.uuid,
                    );
                    ref.invalidate(followingProvider(widget.uuid));
                    ref.invalidate(followerProvider(widget.user.uuid!));
                    ref.invalidate(followerProvider(widget.uuid));
                    ref.invalidate(userProvider(widget.user.uuid!));
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: Text(
                      widget.isFollowing == 0
                          ? "Follow"
                          : widget.isFollowing == 1
                              ? "Unfollow"
                              : "Requested",
                      style: const TextStyle(color: CupertinoColors.white),
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
