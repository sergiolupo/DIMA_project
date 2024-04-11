import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/categories_icon_mapper.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/widgets/home/selectoption_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class UserProfile extends StatefulWidget {
  final UserData user;
  final UserData? visitor;

  const UserProfile({super.key, this.visitor, required this.user});

  @override
  State<UserProfile> createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  late final bool isMyProfile;
  late Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _stream;
  late Stream<List<DocumentSnapshot<Map<String, dynamic>>>> _followersStream;
  bool _isFollowing = false;
  int _groupsCount = 0;
  int _followersCount = 0;
  int _followingCount = 0;
  @override
  void initState() {
    super.initState();
    isMyProfile = widget.visitor == null ||
        widget.visitor!.username == widget.user.username;
    _subscribeToStream();
    debugPrint('isMyProfile: $isMyProfile');
    if (!isMyProfile) _checkFollow();
  }

  _subscribeToStream() {
    _stream = DatabaseService.getGroupsStream(widget.user.username);
    _stream.listen((event) {
      setState(() {
        _groupsCount = event.length;
      });
    });
    _followersStream = DatabaseService.getFollowersStream(widget.user.username);
    _followersStream.listen((event) {
      setState(() {
        _followersCount = event[0].data()!['followers'].length;
        _followingCount = event[0].data()!['following'].length;
      });
    });
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
                        Row(
                          children: [
                            Column(
                              children: [
                                GestureDetector(
                                  onTap: () =>
                                      context.go('/showgroups', extra: {
                                    'user': widget.user,
                                    'visitor': widget.visitor,
                                  }),
                                  child: Column(
                                    children: [
                                      Text(
                                        _groupsCount.toString(),
                                        style: CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle,
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "Groups",
                                        style: CupertinoTheme.of(context)
                                            .textTheme
                                            .textStyle
                                            .copyWith(
                                                color:
                                                    CupertinoColors.systemGrey),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () => context.go('/showfollowers', extra: {
                                'user': widget.user,
                                'visitor': widget.visitor,
                                'followers': true,
                              }),
                              child: Column(
                                children: [
                                  Text(
                                    _followersCount.toString(),
                                    style: CupertinoTheme.of(context)
                                        .textTheme
                                        .textStyle,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Followers",
                                    style: CupertinoTheme.of(context)
                                        .textTheme
                                        .textStyle
                                        .copyWith(
                                            color: CupertinoColors.systemGrey),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 20),
                            GestureDetector(
                              onTap: () => context.go('/showfollowers', extra: {
                                'user': widget.user,
                                'visitor': widget.visitor,
                                'followers': false,
                              }),
                              child: Column(
                                children: [
                                  Text(
                                    _followingCount.toString(),
                                    style: CupertinoTheme.of(context)
                                        .textTheme
                                        .textStyle,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    "Following",
                                    style: CupertinoTheme.of(context)
                                        .textTheme
                                        .textStyle
                                        .copyWith(
                                            color: CupertinoColors.systemGrey),
                                  ),
                                ],
                              ),
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
                                onPressed: () async {
                                  DatabaseService.toggleFollowUnfollow(
                                      widget.user.username,
                                      widget.visitor!.username);
                                  setState(() {
                                    _isFollowing = !_isFollowing;
                                  });
                                },
                                child: Text(
                                  _isFollowing ? 'Unfollow' : 'Follow',
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
                            ],
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

  @override
  void dispose() {
    super.dispose();
    _stream.drain();
  }

  void _signOut(BuildContext context) {
    AuthService.signOut();
    context.go('/login');
  }

  _checkFollow() async {
    await DatabaseService.isFollowing(
            widget.user.username, widget.visitor!.username)
        .then((value) => setState(() {
              _isFollowing = value;
            }));
  }
}
