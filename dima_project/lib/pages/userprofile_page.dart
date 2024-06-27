import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dima_project/pages/chat_page.dart';
import 'package:dima_project/pages/options/options_page.dart';
import 'package:dima_project/widgets/home/user_profile/show_followers_page.dart';
import 'package:dima_project/widgets/home/user_profile/show_groups_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/categories_icon_mapper.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/widgets/home/selectoption_widget.dart';

class UserProfile extends StatefulWidget {
  final UserData user;
  final UserData? visitor;

  const UserProfile({super.key, this.visitor, required this.user});

  @override
  State<UserProfile> createState() => UserProfileState();
}

class UserProfileState extends State<UserProfile> {
  late final bool isMyProfile;

  late final StreamController<List<QueryDocumentSnapshot<Map<String, dynamic>>>>
      _groupsStreamController =
      StreamController<List<QueryDocumentSnapshot<Map<String, dynamic>>>>();

  late final StreamController<DocumentSnapshot<Map<String, dynamic>>>
      _followersStreamController =
      StreamController<DocumentSnapshot<Map<String, dynamic>>>();
  late final StreamController<DocumentSnapshot<Map<String, dynamic>>>
      _followingStreamController =
      StreamController<DocumentSnapshot<Map<String, dynamic>>>();
  late StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
      _followersStreamSubscription;
  late StreamSubscription<List<QueryDocumentSnapshot<Map<String, dynamic>>>>?
      _groupsStreamSubscription;

  bool _isFollowing = false;

  @override
  void initState() {
    super.initState();
    isMyProfile = widget.visitor == null ||
        widget.visitor!.username == widget.user.username;
    _subscribeToStream();
    if (!isMyProfile) _checkFollow();
  }

  _subscribeToStream() {
    _groupsStreamSubscription =
        DatabaseService.getGroupsStreamUser(widget.user.uuid!)
            .listen((snapshot) {
      final dataList =
          snapshot.cast<QueryDocumentSnapshot<Map<String, dynamic>>>();
      _groupsStreamController.add(dataList);
    });

    _followersStreamSubscription =
        DatabaseService.getFollowersStreamUser(widget.user.uuid!)
            .listen((snapshot) {
      _followersStreamController.add(snapshot);
      _followingStreamController.add(snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemPink,
        leading: Navigator.canPop(context)
            ? CupertinoNavigationBarBackButton(
                color: CupertinoColors.white,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : null,
        trailing: isMyProfile
            ? GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => OptionsPage(user: widget.user))),
                child: const Icon(CupertinoIcons.bars,
                    color: CupertinoColors.black),
              )
            : null,
        /*trailing: isMyProfile
            ? GestureDetector(
                onTap: () => _signOut(context),
                child: const Icon(CupertinoIcons.power,
                    color: CupertinoColors.black),
              )
            : const SizedBox(),*/
      ),
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
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    CategoryIconMapper.iconForCategory(
                                        category),
                                    size: 24,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    category,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: CupertinoTheme.of(context)
                                          .primaryColor,
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
                      getGroup(),
                      const SizedBox(width: 20),
                      getFollowers(),
                      const SizedBox(width: 20),
                      getFollowings(),
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
                                    widget.user.uuid!, widget.visitor!.uuid!);
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
                              onPressed: () async {
                                final visitorUid =
                                    await DatabaseService.getUUIDFromUsername(
                                        widget.visitor!.username);
                                final userUid =
                                    await DatabaseService.getUUIDFromUsername(
                                        widget.user.username);
                                var members = [visitorUid, userUid];
                                members.sort();
                                final chat = PrivateChat(
                                  members: members,
                                );
                                if (context.mounted) {
                                  Navigator.of(context, rootNavigator: true)
                                      .push(
                                    CupertinoPageRoute(
                                      builder: (context) => ChatPage(
                                        user: widget.visitor!,
                                        privateChat: chat,
                                      ),
                                    ),
                                  );
                                }
                              },
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
    );
  }

  Widget getGroup() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) =>
                  ShowGroupsPage(user: widget.user, visitor: widget.visitor),
            ),
          ),
          child: SizedBox(
            height: 50,
            child: Column(
              children: [
                StreamBuilder<
                    List<QueryDocumentSnapshot<Map<String, dynamic>>>>(
                  stream: _groupsStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.data!.length.toString(),
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      );
                    } else {
                      return const CupertinoActivityIndicator();
                    }
                  },
                ),
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
          ),
        ),
      ],
    );
  }

  Widget getFollowers() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ShowFollowers(
                  user: widget.user, visitor: widget.visitor, followers: true),
            ),
          ),
          child: SizedBox(
            height: 50,
            child: Column(
              children: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _followersStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.hasData && snapshot.data!.data() != null
                            ? snapshot.data!
                                .data()!["followers"]
                                .length
                                .toString()
                            : '0',
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      );
                    } else {
                      return const CupertinoActivityIndicator();
                    }
                  },
                ),
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
          ),
        ),
      ],
    );
  }

  Widget getFollowings() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (context) => ShowFollowers(
                  user: widget.user, visitor: widget.visitor, followers: false),
            ),
          ),
          child: SizedBox(
            height: 50,
            child: Column(
              children: [
                StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  stream: _followingStreamController.stream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Text(
                        snapshot.hasData && snapshot.data!.data() != null
                            ? snapshot.data!
                                .data()!["following"]
                                .length
                                .toString()
                            : '0',
                        style: CupertinoTheme.of(context).textTheme.textStyle,
                      );
                    } else {
                      return const CupertinoActivityIndicator();
                    }
                  },
                ),
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
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _groupsStreamController.close();
    _followersStreamController.close();
    _followingStreamController.close();
    _followersStreamSubscription?.cancel();
    _groupsStreamSubscription?.cancel();
    super.dispose();
  }

  _checkFollow() async {
    if (widget.visitor != null) {
      // Listen for updates on the isFollowing stream
      final isFollowingStream = DatabaseService.isFollowing(
        widget.user.uuid!,
        widget.visitor!.uuid!,
      );

      // Listen for updates and update _isFollowing accordingly
      await for (final isFollowing in isFollowingStream) {
        if (mounted) {
          setState(() {
            _isFollowing = isFollowing;
          });
        }
      }
    }
  }
}
