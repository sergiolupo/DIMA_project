import 'package:dima_project/models/group.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/utils/create_image_utils.dart';
import 'package:flutter/cupertino.dart';

class GroupInvitationTile extends StatefulWidget {
  final Group group;
  final Function onSelected;
  final bool invited;
  final bool isFirst;
  final bool isLast;
  const GroupInvitationTile({
    super.key,
    required this.group,
    required this.onSelected,
    required this.invited,
    required this.isFirst,
    required this.isLast,
  });

  @override
  GroupInvitationTileState createState() => GroupInvitationTileState();
}

class GroupInvitationTileState extends State<GroupInvitationTile> {
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
          child: CupertinoListTile(
            leading: Transform.scale(
                scale: MediaQuery.of(context).size.width > Constants.limitWidth
                    ? 1.3
                    : 1,
                child: CreateImageUtils.getGroupImage(widget.group.imagePath!)),
            title: Text(
              widget.group.name,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize:
                      MediaQuery.of(context).size.width > Constants.limitWidth
                          ? 20
                          : 17),
            ),
          ),
        ),
        GestureDetector(
          key: const Key('invite_button'),
          onTap: () {
            widget.onSelected(widget.group.id);
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
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Text(
                invited ? 'Invited' : 'Invite',
                style: const TextStyle(color: CupertinoColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
