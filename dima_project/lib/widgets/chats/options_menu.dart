import 'package:flutter/cupertino.dart';

class OptionsMenu extends StatelessWidget {
  final VoidCallback? onTapCreateEvent;
  final VoidCallback onTapCamera;
  final VoidCallback onTapPhoto;
  final OverlayEntry? overlayEntry;
  final bool? isTablet;

  const OptionsMenu({
    super.key,
    this.onTapCreateEvent,
    required this.onTapCamera,
    required this.onTapPhoto,
    required this.overlayEntry,
    this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () {
              overlayEntry?.remove();
            },
            child: Container(
              color: const Color(0x00000000), // Transparent color
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: isTablet! ? MediaQuery.of(context).size.width * 0.4 : 0,
          right: 0,
          child: Container(
            padding: const EdgeInsets.only(top: 10),
            height: 80,
            color: CupertinoColors.inactiveGray,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (onTapCreateEvent != null)
                  GestureDetector(
                    onTap: onTapCreateEvent,
                    child: Column(
                      children: [
                        Icon(CupertinoIcons.calendar,
                            color: CupertinoTheme.of(context).primaryColor),
                        Text(
                          "Event",
                          style: TextStyle(
                            color: CupertinoTheme.of(context)
                                .textTheme
                                .textStyle
                                .color,
                          ),
                        ),
                      ],
                    ),
                  ),
                GestureDetector(
                  onTap: () {
                    onTapCamera();
                    if (overlayEntry?.mounted ?? false) overlayEntry?.remove();
                  },
                  child: Column(
                    children: [
                      Icon(CupertinoIcons.camera_fill,
                          color: CupertinoTheme.of(context).primaryColor),
                      Text(
                        "Camera",
                        style: TextStyle(
                          color: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .color,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onTapPhoto,
                  child: Column(
                    children: [
                      Icon(CupertinoIcons.photo_fill,
                          color: CupertinoTheme.of(context).primaryColor),
                      Text(
                        "Photo",
                        style: TextStyle(
                          color: CupertinoTheme.of(context)
                              .textTheme
                              .textStyle
                              .color,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
