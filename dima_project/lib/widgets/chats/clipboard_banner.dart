import 'package:flutter/cupertino.dart';

class ClipboardBanner extends StatelessWidget {
  final Size size;
  final bool canNavigate;

  const ClipboardBanner(
      {super.key, required this.size, required, required this.canNavigate});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: size.height,
      left: canNavigate ? MediaQuery.of(context).size.width * 0.4 : 0,
      right: 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        child: Container(
          padding:
              const EdgeInsets.only(right: 80, left: 10, bottom: 10, top: 10),
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: CupertinoTheme.of(context).primaryContrastingColor,
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(CupertinoIcons.rectangle_fill_on_rectangle_fill,
                  color: CupertinoTheme.of(context).primaryColor),
              const SizedBox(width: 10),
              Text(
                "Copied to clipboard",
                style:
                    TextStyle(color: CupertinoTheme.of(context).primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
