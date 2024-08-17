import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/group_tile.dart';
import 'package:dima_project/widgets/deleted_account_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowGroupsPage extends ConsumerStatefulWidget {
  final String user;
  const ShowGroupsPage({
    super.key,
    required this.user,
  });

  @override
  ShowGroupsPageState createState() => ShowGroupsPageState();
}

class ShowGroupsPageState extends ConsumerState<ShowGroupsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  final String uid = AuthService.uid;

  @override
  void initState() {
    super.initState();
    ref.read(groupsProvider(widget.user));
  }

  @override
  Widget build(BuildContext context) {
    final groups = ref.watch(groupsProvider(widget.user));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: groups.when(
          data: (data) => CupertinoButton(
            padding: EdgeInsets.zero,
            child: const Icon(CupertinoIcons.back),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          loading: () => const CupertinoActivityIndicator(),
          error: (error, stackTrace) => const SizedBox.shrink(),
        ),
        middle: const Text('Groups'),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: groups.when(
            data: (groups) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: CupertinoSearchTextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {
                        _searchText = _searchController.text;
                      }),
                    ),
                  ),
                  if (groups.isEmpty)
                    SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Image.asset('assets/darkMode/search_groups.png')
                              : Image.asset('assets/images/search_groups.png'),
                          const Center(
                            child: Text('No groups'),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      itemCount: groups.length,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        final group = groups[index];
                        if (!group.name
                            .toLowerCase()
                            .contains(_searchText.toLowerCase())) {
                          if (index == groups.length - 1) {
                            return SingleChildScrollView(
                              physics: const NeverScrollableScrollPhysics(),
                              child: Column(
                                children: [
                                  MediaQuery.of(context).platformBrightness ==
                                          Brightness.dark
                                      ? Image.asset(
                                          'assets/darkMode/no_groups_found.png')
                                      : Image.asset(
                                          'assets/images/no_groups_found.png'),
                                  const Center(
                                    child: Text('No groups found'),
                                  ),
                                ],
                              ),
                            );
                          }
                          return const SizedBox.shrink();
                        }
                        return GroupTile(
                          group: group,
                          isJoined: group.members!.contains(uid)
                              ? 1
                              : group.requests!.contains(uid)
                                  ? 2
                                  : 0,
                        );
                      },
                    ),
                ],
              );
            },
            loading: () => const CupertinoActivityIndicator(),
            error: (error, stackTrace) {
              return const DeletedAccountWidget();
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
