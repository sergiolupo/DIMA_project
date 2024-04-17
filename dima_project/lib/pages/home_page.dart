import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/groups/list_chat_page.dart';
import 'package:dima_project/pages/search_page.dart';
import 'package:dima_project/pages/userprofile_page.dart';
import 'package:dima_project/pages/news/news_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/helper_functions.dart';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  final int? index;
  const HomePage({super.key, this.index});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late int? _currentIndex;
  UserData? _userData;
  final Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {};
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index ?? 0;
    _getUserData();
  }

  void _getUserData() async {
    final uid = await HelperFunctions.getUid();
    final userData = await DatabaseService.getUserData(uid!);
    setState(() {
      _userData = userData;
    });
  }

  @override
  @override
  Widget build(BuildContext context) {
    return _userData == null
        ? const CupertinoPageScaffold(
            child: Center(
              child: CupertinoActivityIndicator(),
            ),
          )
        : CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              currentIndex: _currentIndex!,
              onTap: (index) {
                if (_currentIndex == index) {
                  // Get the current tab's navigator key
                  final navigatorKey = _navigatorKeys[index];
                  // Pop to the first route of the current tab's navigator
                  navigatorKey?.currentState
                      ?.popUntil((route) => route.isFirst);
                } else {
                  setState(() {
                    _currentIndex = index;
                  });
                }
              },
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
                  icon: Icon(CupertinoIcons.add),
                  label: 'Create',
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
                  page = NewsPage(
                    user: _userData!,
                  );
                  break;
                case 1:
                  page = ListChatPage(
                    user: _userData!,
                  );
                  break;
                case 2:
                  page = _buildCreatePage(context);
                  break;
                case 3:
                  page = SearchPage(
                    user: _userData!,
                  );
                  break;
                case 4:
                  page = UserProfile(
                    user: _userData!,
                  );
                  break;
                default:
                  page = _buildNewsPage(context);
              }
              // Initialize a GlobalKey for each tab's navigator
              _navigatorKeys.putIfAbsent(
                  index, () => GlobalKey<NavigatorState>());
              return CupertinoTabView(
                navigatorKey: _navigatorKeys[index], // Assign the navigator key
                builder: (BuildContext context) {
                  return page;
                },
              );
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

  Widget _buildCreatePage(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Create',
          style: TextStyle(
            fontSize: 24, // Adjust font size as needed
            fontWeight: FontWeight.bold, // Adjust font weight as needed
            color: CupertinoColors.black, // Adjust text color as needed
          ),
        ),
      ),
      child: Center(
        child: Text(
          'Create Page',
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
