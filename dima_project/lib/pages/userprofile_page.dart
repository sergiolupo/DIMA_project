import 'package:dima_project/utils/categories_icon_mapper.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/widgets/home/selectoption_widget.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class UserProfile extends StatefulWidget {
  final bool isMyProfile;
  final UserData user;
  const UserProfile({super.key, this.isMyProfile = true, required this.user});

  @override
  State<UserProfile> createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  late final bool isMyProfile;

  @override
  void initState() {
    super.initState();
    isMyProfile = widget.isMyProfile;
  }

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
        trailing: isMyProfile
            ? GestureDetector(
                onTap: () => _signOut(context),
                child: const Icon(CupertinoIcons.power,
                    color: CupertinoColors.black),
              )
            : const SizedBox(),
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
                    CreateImageWidget.getUserImage(widget.user.imagePath!),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        widget.user.username,
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Text(
                        '${widget.user.name} ${widget.user.surname}',
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.user.categories
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
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                CupertinoButton.filled(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 40, vertical: 8),
                                  onPressed: () {},
                                  child: const Text(
                                    'Follow',
                                  ),
                                ),
                                const SizedBox(width: 10),
                                CupertinoButton.filled(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  onPressed: () {},
                                  child: const Icon(
                                    FontAwesomeIcons.envelope,
                                    color: CupertinoColors.white,
                                  ),
                                ),
                              ])
                        : const SizedBox(),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Container(
              color: CupertinoColors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  CustomSelectOption(
                    textLeft: 'Events created',
                    textRight: 'Events joined',
                    onChanged: (value) {},
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
    AuthService.signOut();
    context.go('/login');
  }
}
