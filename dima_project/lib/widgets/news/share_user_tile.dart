import 'package:dima_project/models/user.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:flutter/cupertino.dart';

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
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: CupertinoTheme.of(context).primaryContrastingColor),
        child: CupertinoListTile(
          trailing: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive
                    ? CupertinoTheme.of(context).primaryColor
                    : CupertinoTheme.of(context).scaffoldBackgroundColor,
                shape: BoxShape.circle,
              ),
              child: isActive
                  ? const Icon(
                      CupertinoIcons.checkmark,
                      color: CupertinoColors.white,
                      size: 15,
                    )
                  : Icon(
                      CupertinoIcons.circle,
                      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
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
      ),
      onTap: () {
        setState(() {
          isActive = !isActive;
        });
        widget.onSelected(widget.user.uid!);
      },
    );
  }
}
