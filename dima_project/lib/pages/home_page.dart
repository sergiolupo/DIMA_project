import 'package:dima_project/pages/events/table_calendar_page.dart';
import 'package:dima_project/pages/chats/chat_page.dart';
import 'package:dima_project/pages/chats/chat_tablet_page.dart';
import 'package:dima_project/pages/responsive_layout.dart';
import 'package:dima_project/pages/search_page.dart';
import 'package:dima_project/pages/news/news_page.dart';
import 'package:dima_project/pages/userprofile_page.dart';
import 'package:dima_project/pages/userprofile_tablet_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/notification_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerStatefulWidget {
  final int? index;
  const HomePage({super.key, this.index});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  late int? _currentIndex;
  final Map<int, GlobalKey<NavigatorState>> _navigatorKeys = {};
  NotificationService notificationServices = NotificationService();

  @override
  void initState() {
    notificationServices.requestNotificationPermission();
    notificationServices.forgroundMessage();
    notificationServices.firebaseInit(context);
    notificationServices.setUpInteractMessage(context);
    notificationServices.setupToken(ref);
    ref.read(userProvider(AuthService.uid));
    ref.read(followerProvider(AuthService.uid));
    ref.read(followingProvider(AuthService.uid));
    ref.read(groupsProvider(AuthService.uid));
    ref.read(joinedEventsProvider(AuthService.uid));
    ref.read(createdEventsProvider(AuthService.uid));

    super.initState();
    _currentIndex = widget.index ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
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
            navigatorKey?.currentState?.popUntil((route) => route.isFirst);
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
            icon: Icon(CupertinoIcons.calendar),
            label: 'Calendar',
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
            page = const NewsPage();
            break;
          case 1:
            page = const ResponsiveLayout(
              mobileLayout: ChatPage(),
              tabletLayout: ChatTabletPage(),
            );
            break;
          case 2:
            page = const TableCalendarPage();
            break;
          case 3:
            page = const SearchPage();
            break;
          case 4:
            page = ResponsiveLayout(
              mobileLayout: UserProfile(
                user: AuthService.uid,
              ),
              tabletLayout: UserProfileTablet(
                user: AuthService.uid,
              ),
            );
            break;
          default:
            page = const NewsPage();
        }
        // Initialize a GlobalKey for each tab's navigator
        _navigatorKeys.putIfAbsent(index, () => GlobalKey<NavigatorState>());
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
