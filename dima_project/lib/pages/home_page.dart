import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  final UserData user;
  const HomePage({super.key, required this.user});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  late final UserData user;

  void signOut(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
    context.go('/');
  }

  @override
  void initState() {
    super.initState();
    user = widget.user;
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabScaffold(
      tabBar: CupertinoTabBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(CupertinoIcons.settings),
            label: 'Settings',
          ),
        ],
      ),
      tabBuilder: (BuildContext context, int index) {
        late Widget page;
        switch (index) {
          case 0:
            page = _buildHomePage(context);
            break;
          case 1:
            page = _buildSettingsPage(context);
            break;
          default:
            page = _buildHomePage(context);
        }
        return page;
      },
    );
  }

  Widget _buildHomePage(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text(
          'Home',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.black,
          ),
        ),
        trailing: GestureDetector(
          //onTap: () => _editProfile(context),
          child: const Text(
            'Edit Profile',
            style: TextStyle(
              color: CupertinoColors.black,
              fontSize: 16,
            ),
          ),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (user.imagePath != null)
              CircleAvatar(
                radius: 50,
                backgroundImage: MemoryImage(user.imagePath!),
              ),
            const SizedBox(height: 20),
            Text(
              'Welcome, ${user.name} ${user.surname}!',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Your Interests:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: user.categories
                  .map((category) => Text(
                        '- $category',
                        style: const TextStyle(
                          fontSize: 16,
                          color: CupertinoColors.black,
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsPage(BuildContext context) {
    return const CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: Text(
          'Settings',
          style: TextStyle(
            fontSize: 24, // Adjust font size as needed
            fontWeight: FontWeight.bold, // Adjust font weight as needed
            color: CupertinoColors.black, // Adjust text color as needed
          ),
        ),
      ),
      child: Center(
        child: Text(
          'Settings Page',
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
