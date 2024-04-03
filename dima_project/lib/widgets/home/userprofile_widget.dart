import 'package:dima_project/models/categories.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatelessWidget {
  final UserData user;

  const UserProfile({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'Profile',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: CupertinoColors.systemPink,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ClipOval(
                child: Container(
                  width: 100,
                  height: 100,
                  color: CupertinoColors.lightBackgroundGray,
                  child: user.imagePath != null
                      ? Image.memory(
                          user.imagePath!,
                          fit: BoxFit.cover,
                        )
                      : const Icon(
                          CupertinoIcons.photo,
                          size: 50,
                          color: CupertinoColors.systemGrey,
                        ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '${user.name} ${user.surname}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                user.email,
                style: const TextStyle(
                  fontSize: 18,
                  color: CupertinoColors.black,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Interests:',
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
                    .map(
                      (category) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(
                              CategoryIconMapper.iconForCategory(category),
                              size: 24,
                              color: CupertinoColors.black,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category,
                              style: const TextStyle(
                                fontSize: 16,
                                color: CupertinoColors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Edit Profile',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.black,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        CupertinoIcons.pencil,
                        color: CupertinoColors.systemGrey,
                      ),
                    ],
                  ),
                  CupertinoButton(
                    onPressed: null,
                    child: Icon(
                      CupertinoIcons.arrow_right,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: CupertinoColors.black,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        FontAwesomeIcons.signOutAlt,
                        color: CupertinoColors.systemGrey,
                      ),
                    ],
                  ),
                  CupertinoButton(
                    onPressed: () => _signOut(context),
                    child: const Icon(
                      CupertinoIcons.arrow_right,
                      color: CupertinoColors.systemGrey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _signOut(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    authService.signOut();
    context.go('/');
  }
}
