import 'package:dima_project/models/user.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:flutter/cupertino.dart';

class AddMemberTile extends StatefulWidget {
  final UserData user;
  final ValueChanged<String> onSelected;
  final bool active;
  final bool isJoining;
  @override
  const AddMemberTile({
    super.key,
    required this.user,
    required this.onSelected,
    required this.active,
    required this.isJoining,
  });

  @override
  State<AddMemberTile> createState() => AddMemberTileState();
}

class AddMemberTileState extends State<AddMemberTile> {
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
      child: CupertinoListTile(
        trailing: Container(
            padding: const EdgeInsets.all(10),
            decoration: widget.isJoining
                ? const BoxDecoration()
                : BoxDecoration(
                    color: isActive
                        ? CupertinoTheme.of(context).primaryColor
                        : CupertinoTheme.of(context).scaffoldBackgroundColor,
                    shape: BoxShape.circle,
                  ),
            child: widget.isJoining
                ? const SizedBox.shrink()
                : isActive
                    ? const Icon(
                        CupertinoIcons.checkmark,
                        color: CupertinoColors.white,
                        size: 15,
                      )
                    : Icon(
                        CupertinoIcons.circle,
                        color:
                            CupertinoTheme.of(context).scaffoldBackgroundColor,
                        size: 15,
                      )),
        leading: Stack(
          children: [
            ClipOval(
              child: Container(
                width: 100,
                height: 100,
                color: CupertinoColors.lightBackgroundGray,
                child:
                    CreateImageWidget.getUserImage(widget.user.imagePath!, 1),
              ),
            ),
          ],
        ),
        title: Text(
          widget.user.username,
          style: TextStyle(
              color: CupertinoTheme.of(context).textTheme.textStyle.color,
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text("${widget.user.name} ${widget.user.surname}"),
      ),
      onTap: () {
        if (widget.isJoining) {
          return;
        }
        setState(() {
          isActive = !isActive;
        });
        widget.onSelected(widget.user.uid!);
      },
    );
  }
}
