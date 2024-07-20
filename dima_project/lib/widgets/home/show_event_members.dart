import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/home/user_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowEventMembersPage extends ConsumerStatefulWidget {
  final String eventId;
  final String uuid;
  final String detailId;
  final String admin;
  const ShowEventMembersPage({
    super.key,
    required this.eventId,
    required this.uuid,
    required this.detailId,
    required this.admin,
  });

  @override
  ShowEventMembersPageState createState() => ShowEventMembersPageState();
}

class ShowEventMembersPageState extends ConsumerState<ShowEventMembersPage> {
  @override
  void initState() {
    ref.read(followingProvider(widget.uuid));
    ref.read(eventProvider(widget.eventId));
    ref.read(userProvider(widget.uuid));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final event = ref.watch(eventProvider(widget.eventId));
    final followings = ref.watch(followingProvider(widget.uuid));
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        middle: Text('Partecipants',
            style: TextStyle(color: CupertinoTheme.of(context).primaryColor)),
      ),
      child: event.when(
        data: (event) {
          final detail = event.details!.firstWhere(
            (element) => element.id == widget.detailId,
            orElse: () => throw Exception('Detail not found'),
          );
          return ListView.builder(
            itemCount: detail.members!.length,
            itemBuilder: (context, index) {
              final user = ref.watch(userProvider(detail.members![index]));

              return user.when(
                data: (userData) {
                  return followings.when(
                      data: (followings) {
                        final isFollowing = followings
                                .any((element) => element.uuid! == widget.uuid)
                            ? 1
                            : userData.requests!.contains(widget.uuid)
                                ? 2
                                : 0;

                        if (userData.uuid == widget.admin) {
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: UserTile(
                                  user: userData,
                                  uuid: widget.uuid,
                                  isFollowing: isFollowing,
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(right: 8.0),
                                child: Text(
                                  "Host",
                                  style: TextStyle(
                                    color: CupertinoColors.systemGrey4,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          );
                        }

                        return UserTile(
                          user: userData,
                          uuid: widget.uuid,
                          isFollowing: isFollowing,
                        );
                      },
                      loading: () => const CupertinoActivityIndicator(),
                      error: (error, stack) => Text('Error: $error'));
                },
                loading: () => const CupertinoActivityIndicator(),
                error: (error, stack) => Text('Error: $error'),
              );
            },
          );
        },
        loading: () => const CupertinoActivityIndicator(),
        error: (error, stack) => Text('Error: $error'),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
