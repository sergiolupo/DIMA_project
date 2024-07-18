import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/home/user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowFollowing extends ConsumerWidget {
  final String user;
  final String uuid;

  const ShowFollowing({
    super.key,
    required this.user,
    required this.uuid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<UserData>> asyncUsers =
        ref.watch(followingProvider(user));
    final AsyncValue<List<UserData>> asyncFollowing =
        ref.watch(followingProvider(uuid));
    final TextEditingController searchController = TextEditingController();
    String searchText = '';

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        middle: const Text('Following'),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: CupertinoSearchTextField(
                controller: searchController,
                onChanged: (_) {
                  searchText = searchController.text;
                },
              ),
            ),
            asyncUsers.when(
              loading: () => const CupertinoActivityIndicator(),
              error: (err, stack) => Center(child: Text('Error: $err')),
              data: (users) {
                if (users.isEmpty) {
                  return Column(
                    children: [
                      Image.asset('assets/images/no_following_found.png'),
                      const Center(
                        child: Text('Not following anyone'),
                      ),
                    ],
                  );
                }
                final filteredUsers = users.where((user) {
                  return user.username
                      .toLowerCase()
                      .contains(searchText.toLowerCase());
                }).toList();

                if (filteredUsers.isEmpty) {
                  return Column(
                    children: [
                      Image.asset('assets/images/search_following.png'),
                      const Center(
                        child: Text('Not following anyone'),
                      ),
                    ],
                  );
                }

                return Expanded(
                  child: ListView.builder(
                    itemCount: filteredUsers.length,
                    itemBuilder: (context, index) {
                      final userData = filteredUsers[index];

                      return asyncFollowing.when(
                        loading: () => const CupertinoActivityIndicator(),
                        error: (err, stack) => Text('Error: $err'),
                        data: (following) {
                          return UserTile(
                            user: userData,
                            uuid: uuid,
                            isFollowing:
                                following.any((u) => u.uuid == userData.uuid)
                                    ? 1
                                    : userData.isPublic == false &&
                                            userData.requests!.contains(uuid)
                                        ? 2
                                        : 0,
                          );
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
