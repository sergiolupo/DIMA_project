import 'package:dima_project/pages/events/create_event_page.dart';
import 'package:dima_project/pages/groups/list_chat_page.dart';
import 'package:dima_project/pages/search_page.dart';
import 'package:dima_project/pages/userprofile_page.dart';
import 'package:dima_project/pages/news/news_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/helper_functions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  final int? index;
  const HomePage({super.key, this.index});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  late int? _currentIndex;
  String? uuid;
  final Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {};
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.index ?? 0;
    _getUserData();
    DatabaseService.updateActiveStatus(true);
    //for updating the active status of the user
    //resume -> online
    //pause -> offline
    SystemChannels.lifecycle.setMessageHandler((message) {
      if (message.toString().contains("pause")) {
        DatabaseService.updateActiveStatus(false);
      }
      if (message.toString().contains("resume")) {
        DatabaseService.updateActiveStatus(true);
      }
      return Future.value(message);
    });
  }

  void _getUserData() async {
    final userUuid = await HelperFunctions.getUid();
    setState(() {
      uuid = userUuid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return uuid == null
        ? const CupertinoActivityIndicator()
        : CupertinoTabScaffold(
            tabBar: CupertinoTabBar(
              backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
              currentIndex: _currentIndex!,
              onTap: (index) {
                ref.invalidate(userProvider);
                ref.invalidate(followerProvider);
                ref.invalidate(followingProvider);
                ref.invalidate(groupsProvider);
                ref.invalidate(joinedEventsProvider);
                ref.invalidate(createdEventsProvider);
                ref.invalidate(eventProvider);
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
                    uuid: uuid!,
                  );
                  break;
                case 1:
                  page = ListChatPage(
                    uuid: uuid!,
                  );
                  break;
                case 2:
                  page = CreateEventPage(uuid: uuid!);
                  break;
                case 3:
                  page = SearchPage(
                    uuid: uuid!,
                  );
                  break;
                case 4:
                  page = UserProfile(
                    uuid: uuid!,
                    user: uuid!,
                  );
                  break;
                default:
                  page = NewsPage(
                    uuid: uuid!,
                  );
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
}
