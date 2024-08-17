import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/deleted_account_widget.dart';
import 'package:dima_project/widgets/user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowFollowingPage extends ConsumerStatefulWidget {
  final String user;
  const ShowFollowingPage({
    super.key,
    required this.user,
  });

  @override
  ShowFollowingPageState createState() => ShowFollowingPageState();
}

class ShowFollowingPageState extends ConsumerState<ShowFollowingPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  final String uid = AuthService.uid;

  @override
  void initState() {
    ref.read(followingProvider(widget.user));
    ref.read(followingProvider(uid));
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final AsyncValue<List<UserData>> asyncUsers =
        ref.watch(followingProvider(widget.user));
    final AsyncValue<List<UserData>> asyncFollowing =
        ref.watch(followingProvider(uid));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: asyncUsers.when(
          data: (data) => CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          loading: () => const CupertinoActivityIndicator(),
          error: (err, stack) => const SizedBox.shrink(),
        ),
        middle: const Text('Following'),
      ),
      child: SafeArea(
        child: asyncUsers.when(
          loading: () => const CupertinoActivityIndicator(),
          error: (err, stack) => const DeletedAccountWidget(),
          data: (users) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: CupertinoSearchTextField(
                    controller: _searchController,
                    onChanged: (_) {
                      setState(() {
                        _searchText = _searchController.text;
                      });
                    },
                  ),
                ),
                if (users.isEmpty)
                  Column(
                    children: [
                      MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Image.asset(
                              'assets/darkMode/no_following_found.png')
                          : Image.asset('assets/images/no_following_found.png'),
                      const Center(
                        child: Text('Not following anyone'),
                      ),
                    ],
                  )
                else
                  ListView.builder(
                    physics: const ClampingScrollPhysics(),
                    itemCount: users.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final user = users[index];
                      if (!user.username
                          .toLowerCase()
                          .contains(_searchText.toLowerCase())) {
                        if (index == users.length - 1) {
                          return Column(
                            children: [
                              MediaQuery.of(context).platformBrightness ==
                                      Brightness.dark
                                  ? Image.asset(
                                      'assets/darkMode/search_following.png')
                                  : Image.asset(
                                      'assets/images/search_following.png'),
                              const Center(
                                child: Text('Not following found'),
                              ),
                            ],
                          );
                        }
                        return const SizedBox.shrink();
                      }

                      return asyncFollowing.when(
                        loading: () => const CupertinoActivityIndicator(),
                        error: (err, stack) => Text('Error: $err'),
                        data: (following) {
                          return UserTile(
                            user: user,
                            isFollowing: following.any((u) => u.uid == user.uid)
                                ? 1
                                : user.isPublic == false &&
                                        user.requests!.contains(uid)
                                    ? 2
                                    : 0,
                          );
                        },
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
