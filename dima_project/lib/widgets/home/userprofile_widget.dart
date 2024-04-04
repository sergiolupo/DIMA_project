import 'package:dima_project/models/categories.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/widgets/home/binaryoption_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class UserProfile extends StatelessWidget {
  final UserData user;
  final bool isMyProfile;
  const UserProfile({super.key, required this.user, this.isMyProfile = true});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.white,
        leading: isMyProfile
            ? GestureDetector(
                onTap: () {},
                child: const Icon(CupertinoIcons.settings,
                    color: CupertinoColors.black),
              )
            : const SizedBox(),
        trailing: GestureDetector(
          onTap: () {},
          child: const Icon(CupertinoIcons.share, color: CupertinoColors.black),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              color: CupertinoColors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 55),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
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
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        user.username,
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        '${user.name} ${user.surname}',
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: user.categories
                          .map((category) => Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Icon(
                                      CategoryIconMapper.iconForCategory(
                                          category),
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
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text("789",
                                style: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle),
                            const SizedBox(height: 10),
                            Text(
                              "Groups",
                              style: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .copyWith(color: CupertinoColors.systemGrey),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text("1.2000",
                                style: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle),
                            const SizedBox(height: 10),
                            Text(
                              "Followers",
                              style: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .copyWith(color: CupertinoColors.systemGrey),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text("789",
                                style: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle),
                            const SizedBox(height: 10),
                            Text(
                              "Following",
                              style: CupertinoTheme.of(context)
                                  .textTheme
                                  .textStyle
                                  .copyWith(color: CupertinoColors.systemGrey),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    !isMyProfile
                        ? CupertinoButton.filled(
                            onPressed: () {},
                            child: const Text(
                              'Follow',
                            ),
                          )
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: CupertinoColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Column(
                children: [
                  CustomBinaryOption(
                    textLeft: 'Events created',
                    textRight: 'Events joined',
                  ),
                  /*GridView.count(
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    childAspectRatio: 1 / 1.5,
                    children: List.generate(5, (index) => const Placeholder()),
                  ),*/
                ],
              ),
            ),
          ],
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
