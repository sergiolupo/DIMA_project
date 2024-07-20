import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/options/options_page.dart';
import 'package:dima_project/pages/private_chat_page.dart';
import 'package:dima_project/pages/show_event.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/event_grid.dart';
import 'package:dima_project/widgets/home/user_profile/show_followers_page.dart';
import 'package:dima_project/widgets/home/user_profile/show_following_page.dart';
import 'package:dima_project/widgets/home/user_profile/show_groups_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:dima_project/models/private_chat.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/categories_icon_mapper.dart';
import 'package:dima_project/widgets/image_widget.dart';
import 'package:dima_project/widgets/home/selectoption_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile extends ConsumerStatefulWidget {
  final String uuid;
  final String user;
  @override
  const UserProfile({super.key, required this.user, required this.uuid});

  @override
  UserProfileState createState() => UserProfileState();
}

class UserProfileState extends ConsumerState<UserProfile> {
  late final bool isMyProfile;

// 0 is not following, 1 is following, 2 is requested

  int index = 0;
  bool navigatorCanPop = false;
  @override
  void initState() {
    super.initState();
    isMyProfile = widget.uuid == widget.user;
    ref.read(userProvider(widget.user));
    ref.read(followerProvider(widget.user));
    ref.read(followingProvider(widget.user));
    ref.read(followingProvider(widget.uuid));
    ref.read(groupsProvider(widget.user));
    ref.read(joinedEventsProvider(widget.user));
    ref.read(createdEventsProvider(widget.user));
    setState(() {
      navigatorCanPop = canNavigatorPop(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider(widget.user));

    return user.when(
      data: (user) {
        return _buildProfile(user);
      },
      loading: () => const CupertinoActivityIndicator(),
      error: (error, stackTrace) {
        return Center(
          child: Text('Error: $error'),
        );
      },
    );
  }

  bool canNavigatorPop(BuildContext context) {
    return Navigator.of(context).canPop();
  }

  Widget _buildProfile(UserData user) {
    final followings = ref.watch(followingProvider(widget.uuid));
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
        leading: (navigatorCanPop)
            ? CupertinoNavigationBarBackButton(
                color: CupertinoTheme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  user.username,
                  style: TextStyle(
                    color: CupertinoTheme.of(context).textTheme.textStyle.color,
                    fontSize: 25,
                  ),
                ),
              ),
        middle: navigatorCanPop
            ? Text(
                user.username,
                style: TextStyle(
                  color: CupertinoTheme.of(context).textTheme.textStyle.color,
                  fontSize: 20,
                ),
              )
            : null,
        trailing: isMyProfile
            ? GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    CupertinoPageRoute(
                        builder: (context) => OptionsPage(uuid: widget.uuid))),
                child: Icon(CupertinoIcons.bars,
                    color:
                        CupertinoTheme.of(context).textTheme.textStyle.color),
              )
            : null,
      ),
      child: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 20, right: 2),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            CreateImageWidget.getUserImage(user.imagePath!),
                            Padding(
                              padding: const EdgeInsets.only(top: 10.0),
                              child: Text(
                                '${user.name} ${user.surname}',
                                style: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 35),
                        getGroups(),
                        const SizedBox(width: 20),
                        getFollowers(),
                        const SizedBox(width: 20),
                        getFollowings(),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Column(
                  children: user.categories
                      .map((category) => Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 4, horizontal: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  CategoryIconMapper.iconForCategory(category),
                                  size: 24,
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  category,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 20),
                const SizedBox(height: 20),
                !isMyProfile
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 8),
                            onPressed: () async {
                              await DatabaseService.toggleFollowUnfollow(
                                  widget.user, widget.uuid);
                              ref.invalidate(followingProvider(widget.uuid));
                              ref.invalidate(followerProvider(widget.user));
                            },
                            child: followings.when(
                              data: (followings) {
                                return Text(
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                    ),
                                    followings.any((element) =>
                                            element.uuid! == widget.user)
                                        ? "Unfollow"
                                        : user.requests!.contains(widget.user)
                                            ? "Requested"
                                            : "Follow");
                              },
                              loading: () => const CupertinoActivityIndicator(),
                              error: (error, stackTrace) {
                                return Center(
                                  child: Text('Error: $error'),
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          CupertinoButton.filled(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            onPressed: () async {
                              var members = [widget.uuid, widget.user];
                              members.sort();
                              final chat = PrivateChat(
                                members: members,
                              );
                              if (context.mounted) {
                                Navigator.of(context, rootNavigator: true).push(
                                  CupertinoPageRoute(
                                    builder: (context) => PrivateChatPage(
                                      uuid: widget.uuid,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                CustomSelectOption(
                  textLeft: 'Events created',
                  textRight: 'Events joined',
                  onChanged: (value) {
                    setState(() {
                      index = value;
                    });
                  },
                ),
                getCreatedEvents(user),
                getJoinedEvents(user),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget getJoinedEvents(UserData user) {
    final events = ref.watch(joinedEventsProvider(widget.user));

    return Visibility(
      visible: index == 1,
      child: events.when(
          data: (events) {
            return Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                  ),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ShowEvent(
                            uuid: widget.uuid,
                            eventId: event.id!,
                            userData: user,
                            createdEvents: false,
                          ),
                        ),
                      ),
                      child: EventGrid(
                        uuid: widget.uuid,
                        event: event,
                      ),
                    );
                  },
                ),
              ],
            );
          },
          error: (error, stackTrace) {
            return Center(
              child: Text('Error: $error'),
            );
          },
          loading: () => const CupertinoActivityIndicator()),
    );
  }

  Widget getCreatedEvents(UserData user) {
    final events = ref.watch(createdEventsProvider(widget.user));

    return Visibility(
      visible: index == 0,
      child: events.when(
          data: (events) {
            return Column(
              children: [
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 5.0,
                    mainAxisSpacing: 5.0,
                  ),
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => ShowEvent(
                            uuid: widget.uuid,
                            eventId: event.id!,
                            createdEvents: true,
                            userData: user,
                          ),
                        ),
                      ),
                      child: EventGrid(
                        uuid: widget.uuid,
                        event: event,
                      ),
                    );
                  },
                ),
              ],
            );
          },
          error: (error, stackTrace) {
            return Center(
              child: Text('Error: $error'),
            );
          },
          loading: () => const CupertinoActivityIndicator()),
    );
  }

  Widget getGroups() {
    final groups = ref.watch(groupsProvider(widget.user));

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ref.invalidate(groupsProvider(widget.user));
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) =>
                    ShowGroupsPage(user: widget.user, uuid: widget.uuid),
              ),
            );
          },
          child: SizedBox(
            height: 50,
            child: Column(
              children: [
                groups.when(
                  data: (groups) {
                    return Text(
                      groups.length.toString(),
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                    );
                  },
                  loading: () => const CupertinoActivityIndicator(),
                  error: (error, stackTrace) {
                    return Center(
                      child: Text('Error: $error'),
                    );
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
    final followers = ref.watch(followerProvider(widget.user));

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ref.invalidate(followerProvider(widget.user));
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ShowFollowers(
                  user: widget.user,
                  uuid: widget.uuid,
                ),
              ),
            );
          },
          child: SizedBox(
            height: 50,
            child: Column(
              children: [
                followers.when(
                  data: (followers) {
                    return Text(
                      followers.length.toString(),
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                    );
                  },
                  loading: () => const CupertinoActivityIndicator(),
                  error: (error, stackTrace) {
                    return Center(
                      child: Text('Error: $error'),
                    );
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
    final following = ref.watch(followingProvider(widget.user));

    return Column(
      children: [
        GestureDetector(
          onTap: () {
            ref.invalidate(followingProvider(widget.user));
            Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (context) => ShowFollowing(
                  user: widget.user,
                  uuid: widget.uuid,
                ),
              ),
            );
          },
          child: SizedBox(
            height: 50,
            child: Column(
              children: [
                following.when(
                  data: (following) {
                    return Text(
                      following.length.toString(),
                      style: CupertinoTheme.of(context).textTheme.textStyle,
                    );
                  },
                  loading: () => const CupertinoActivityIndicator(),
                  error: (error, stackTrace) {
                    return Center(
                      child: Text('Error: $error'),
                    );
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
    super.dispose();
  }
}
