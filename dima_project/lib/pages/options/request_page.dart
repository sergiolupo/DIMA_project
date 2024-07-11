import 'package:dima_project/pages/events/events_requests_page.dart';
import 'package:dima_project/pages/follow_requests_page.dart';
import 'package:dima_project/pages/groups_requests_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:flutter/cupertino.dart';

class ShowRequestPage extends StatefulWidget {
  final String uuid;
  const ShowRequestPage({super.key, required this.uuid});
  @override
  ShowRequestPageState createState() => ShowRequestPageState();
}

class ShowRequestPageState extends State<ShowRequestPage> {
  Stream<int>? _numFollowRequests;
  Stream<int>? _numGroupRequests;
  Stream<int>? _numEventRequests;
  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    _numFollowRequests = DatabaseService.getFollowRequests(widget.uuid).map(
      (follow) {
        return follow.length;
      },
    );
    _numGroupRequests = DatabaseService.getUserGroupRequests(widget.uuid).map(
      (group) {
        return group.length;
      },
    );
    _numEventRequests = DatabaseService.getEventRequestsStream(widget.uuid).map(
      (event) {
        return event.length;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _numFollowRequests == null || _numEventRequests == null
        ? const Center(child: CupertinoActivityIndicator())
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                backgroundColor: CupertinoColors.systemPink,
                middle: const Text('Requests'),
                leading: CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  padding: const EdgeInsets.only(left: 10),
                  color: CupertinoColors.systemPink,
                  child: const Icon(CupertinoIcons.back),
                )),
            child: SafeArea(
              child: ListView(
                children: [
                  CupertinoListSection(
                    children: [
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.person),
                        onTap: () => {
                          Navigator.of(context, rootNavigator: true).push(
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      FollowRequestsPage(uuid: widget.uuid)))
                        },
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Follow Requests'),
                            StreamBuilder<int>(
                              stream: _numFollowRequests,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data! > 0
                                      ? Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: CupertinoColors.systemRed,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            snapshot.data.toString(),
                                            style: const TextStyle(
                                              color: CupertinoColors.white,
                                            ),
                                          ),
                                        )
                                      : const SizedBox();
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      CupertinoListTile(
                        leading:
                            const Icon(CupertinoIcons.person_2_square_stack),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Group Requests'),
                            StreamBuilder<int>(
                              stream: _numGroupRequests,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data! > 0
                                      ? Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: CupertinoColors.systemRed,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            snapshot.data.toString(),
                                            style: const TextStyle(
                                              color: CupertinoColors.white,
                                            ),
                                          ),
                                        )
                                      : const SizedBox();
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () => {
                          Navigator.of(context, rootNavigator: true).push(
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      GroupsRequestsPage(uuid: widget.uuid)))
                        },
                      ),
                      CupertinoListTile(
                        leading: const Icon(CupertinoIcons.calendar_badge_plus),
                        title: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Event Requests'),
                            StreamBuilder<int>(
                              stream: _numEventRequests,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return snapshot.data! > 0
                                      ? Container(
                                          padding: const EdgeInsets.all(4),
                                          decoration: BoxDecoration(
                                            color: CupertinoColors.systemRed,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            snapshot.data.toString(),
                                            style: const TextStyle(
                                              color: CupertinoColors.white,
                                            ),
                                          ),
                                        )
                                      : const SizedBox();
                                } else {
                                  return const SizedBox();
                                }
                              },
                            ),
                          ],
                        ),
                        onTap: () => {
                          Navigator.of(context, rootNavigator: true).push(
                              CupertinoPageRoute(
                                  builder: (context) =>
                                      EventsRequestsPage(uuid: widget.uuid)))
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
  }
}

class CupertinoListTile extends StatelessWidget {
  final Widget leading;
  final Widget title;
  final VoidCallback? onTap;

  const CupertinoListTile(
      {super.key, required this.leading, required this.title, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 16),
            Expanded(child: title),
            const Icon(CupertinoIcons.forward),
          ],
        ),
      ),
    );
  }
}

class CupertinoListSection extends StatelessWidget {
  final List<Widget> children;

  const CupertinoListSection({super.key, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }
}
