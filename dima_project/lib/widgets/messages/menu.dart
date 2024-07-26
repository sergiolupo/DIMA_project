import 'package:flutter/cupertino.dart';
import 'package:pull_down_button/pull_down_button.dart';

@immutable
class ExampleMenu extends StatelessWidget {
  final bool sentByMe;
  const ExampleMenu({
    super.key,
    required this.builder,
    required this.sentByMe,
  });

  final PullDownMenuButtonBuilder builder;

  @override
  Widget build(BuildContext context) {
    return PullDownButton(
      itemBuilder: (context) => [
        PullDownMenuItem(
          onTap: () {},
          title: 'Pin',
          icon: CupertinoIcons.pin,
        ),
        PullDownMenuItem(
          title: 'Forward',
          subtitle: 'Share in different channel',
          onTap: () {},
          icon: CupertinoIcons.arrowshape_turn_up_right,
        ),
        PullDownMenuItem(
          onTap: () {},
          title: 'Delete',
          isDestructive: true,
          icon: CupertinoIcons.delete,
        ),
      ],
      animationBuilder: (context, animation, child) => Align(
        alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: child,
      ),
      position: PullDownMenuPosition.automatic,
      buttonBuilder: builder,
    );
  }
}
