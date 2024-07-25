import 'package:dima_project/pages/groups/chat_page.dart';
import 'package:dima_project/pages/groups/chat_tablet_page.dart';

import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';

class ResponsiveChatPage extends StatelessWidget {
  @override
  const ResponsiveChatPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > Constants.limitWidth) {
      return const ChatTabletPage();
    } else {
      return const ChatPage();
    }
  }
}
