import 'package:dima_project/models/user.dart';
import 'package:dima_project/widgets/home/userprofile_widget.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  final UserData? user;
  const HomePage({super.key, this.user});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late final UserData user;

  @override
  void initState() {
    super.initState();
    user = widget.user!;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.news),
            label: 'News',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.chat_bubble),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        late Widget page;
        switch (index) {
          case 0:
            page = _buildNewsPage(context);
            break;
          case 1:
            page = _buildChatPage(context);
            break;
          case 2:
            page = _buildSearchPage(context);
            break;
          case 3:
            page = UserProfile(user: user);
            break;
          default:
            page = _buildNewsPage(context);
        }
        return page;
      },
    );
  }

  Widget _buildNewsPage(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'News',
          style: TextStyle(
            fontSize: 24, // Adjust font size as needed
            fontWeight: FontWeight.bold, // Adjust font weight as needed
            color: CupertinoColors.black, // Adjust text color as needed
          ),
        ),
      ),
      child: Center(
        child: Text(
          'News Page',
          style: TextStyle(
            fontSize: 24, // Adjust font size as needed
            fontWeight: FontWeight.bold, // Adjust font weight as needed
            color: CupertinoColors.black, // Adjust text color as needed
          ),
        ),
      ),
    );
  }

  Widget _buildChatPage(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Chat',
          style: TextStyle(
            fontSize: 24, // Adjust font size as needed
            fontWeight: FontWeight.bold, // Adjust font weight as needed
            color: CupertinoColors.black, // Adjust text color as needed
          ),
        ),
      ),
      child: Center(
        child: Text(
          'Chat Page',
          style: TextStyle(
            fontSize: 24, // Adjust font size as needed
            fontWeight: FontWeight.bold, // Adjust font weight as needed
            color: CupertinoColors.black, // Adjust text color as needed
          ),
        ),
      ),
    );
  }

  Widget _buildSearchPage(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Search',
          style: TextStyle(
            fontSize: 24, // Adjust font size as needed
            fontWeight: FontWeight.bold, // Adjust font weight as needed
            color: CupertinoColors.black, // Adjust text color as needed
          ),
        ),
      ),
      child: Center(
        child: Text(
          'Search Page',
          style: TextStyle(
            fontSize: 24, // Adjust font size as needed
            fontWeight: FontWeight.bold, // Adjust font weight as needed
            color: CupertinoColors.black, // Adjust text color as needed
          ),
        ),
      ),
    );
  }
}
