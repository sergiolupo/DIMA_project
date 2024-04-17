import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/userprofile_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';

class UserTile extends StatefulWidget {
  final UserData user;
  final UserData visitor;
  const UserTile({
    super.key,
    required this.user,
    required this.visitor,
  });

  @override
  UserTileState createState() => UserTileState();
}

class UserTileState extends State<UserTile> {
  bool _isFollowing = false;
  @override
  void initState() {
    super.initState();
    _checkFollowing();
  }

  _checkFollowing() async {
    try {
      await DatabaseService.isFollowing(
        widget.user.username,
        widget.visitor.username,
      ).then((isFollowing) {
        if (mounted) {
          setState(() {
            _isFollowing = isFollowing;
          });
        }
      });
    } catch (error) {
      debugPrint("Error occurred: $error");
      if (mounted) {
        setState(() {
          _isFollowing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return UserProfile(
                  user: widget.user,
                  visitor: widget.visitor,
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
        widget.user.username != widget.visitor.username
            ? GestureDetector(
                onTap: () async {
                  try {
                    DatabaseService.toggleFollowUnfollow(
                      widget.user.username,
                      widget.visitor.username,
                    );

                    if (mounted) {
                      setState(() {
                        _isFollowing = !_isFollowing;
                      });
                    }
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
                    child: Text(
                      _isFollowing ? "Following" : "Follow",
                      style: const TextStyle(color: CupertinoColors.white),
                    ),
                  ),
                ),
              )
            : const SizedBox(),
      ],
    );
  }
}
