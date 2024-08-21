import 'package:dima_project/models/group.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:flutter/cupertino.dart';

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
                child: CreateImageWidget.getGroupImage(widget.group.imagePath!),
              ),
            ),
          ],
        ),
        title: Text(
          widget.group.name,
          style: TextStyle(
              color: CupertinoTheme.of(context).textTheme.textStyle.color,
              fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          widget.group.description!,
          style: TextStyle(
            color: CupertinoTheme.of(context).textTheme.textStyle.color,
          ),
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
