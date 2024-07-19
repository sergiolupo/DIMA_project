import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/widgets/home/group_tile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ShowGroupsPage extends ConsumerStatefulWidget {
  final String user;
  final String uuid;
  const ShowGroupsPage({
    super.key,
    required this.user,
    required this.uuid,
  });

  @override
  ShowGroupsPageState createState() => ShowGroupsPageState();
}

class ShowGroupsPageState extends ConsumerState<ShowGroupsPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';
  @override
  void initState() {
    super.initState();
    ref.read(groupsProvider(widget.user));
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        middle: const Text('Groups'),
      ),
      child: SafeArea(
        child: Column(children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: CupertinoSearchTextField(
                controller: _searchController,
                onChanged: (_) => (setState(() {
                      _searchText = _searchController.text;
                    }))),
          ),
          Consumer(builder: (context, ref, _) {
            final groups = ref.watch(groupsProvider(widget.user));
            return groups.when(
              data: (groups) {
                if (groups.isEmpty) {
                  return Column(
                    children: [
                      MediaQuery.of(context).platformBrightness ==
                              Brightness.dark
                          ? Image.asset('assets/darkMode/search_groups.png')
                          : Image.asset('assets/images/search_groups.png'),
                      const Center(
                        child: Text('No groups'),
                      ),
                    ],
                  );
                }
                int i = 0;
                return ListView.builder(
                    itemCount: groups.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      if (!group.name
                          .toLowerCase()
                          .contains(_searchText.toLowerCase())) {
                        i += 1;
                        if (i == groups.length) {
                          return Column(
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
                          );
                        }
                        return const SizedBox.shrink();
                      }
                      return GroupTile(
                          uuid: widget.uuid,
                          group: group,
                          isJoined: group.members!.contains(widget.uuid)
                              ? 1
                              : group.requests!.contains(widget.uuid)
                                  ? 2
                                  : 0);
                    });
              },
              loading: () => const CupertinoActivityIndicator(),
              error: (error, stackTrace) {
                debugPrint('Error: $error');
                return const Text('Error');
              },
            );
          }),
        ]),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
