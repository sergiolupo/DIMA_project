import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/responsive_layout.dart';
import 'package:dima_project/pages/user_profile/user_profile_page.dart';
import 'package:dima_project/pages/user_profile/user_profile_tablet_page.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:flutter/cupertino.dart';

class UserInvitationTile extends StatefulWidget {
  final UserData user;
  final ValueChanged<String> invitePageKey;
  final bool invited;
  final bool isJoining;
  const UserInvitationTile({
    super.key,
    required this.user,
    required this.invitePageKey,
    required this.invited,
    required this.isJoining,
  });

  @override
  UserInvitationTileState createState() => UserInvitationTileState();
}

class UserInvitationTileState extends State<UserInvitationTile> {
  bool invited = false;
  @override
  void initState() {
    invited = widget.invited;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(context, CupertinoPageRoute(builder: (context) {
                return ResponsiveLayout(
                  mobileLayout: UserProfile(
                    user: widget.user.uid!,
                  ),
                  tabletLayout: UserProfileTablet(
                    user: widget.user.uid!,
                  ),
                );
              }));
            },
            child: CupertinoListTile(
              leading: ClipOval(
                child: Container(
                  width: 100,
                  height: 100,
                  color: CupertinoColors.lightBackgroundGray,
                  child:
                      CreateImageUtils.getUserImage(widget.user.imagePath!, 1),
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
        widget.isJoining
            ? const SizedBox.shrink()
            : GestureDetector(
                key: const Key('invite_button'),
                onTap: () {
                  widget.invitePageKey(widget.user.uid!);
                  setState(() {
                    invited = !invited;
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
                    child: Text(
                      invited ? 'Invited' : 'Invite',
                      style: const TextStyle(color: CupertinoColors.white),
                    ),
                  ),
                ),
              )
      ],
    );
  }
}
