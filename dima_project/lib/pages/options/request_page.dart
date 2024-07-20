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
  int? _numFollowRequests;
  int? _numGroupRequests;
  int? _numEventRequests;
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    int? number;
    number = (await DatabaseService.getFollowRequests(widget.uuid)).length;
    setState(() {
      _numFollowRequests = number;
    });
    number = (await DatabaseService.getUserGroupRequests(widget.uuid)).length;
    setState(() {
      _numGroupRequests = number;
    });
    number =
        (await DatabaseService.getEventRequestsForUser(widget.uuid)).length;
    setState(() {
      _numEventRequests = number;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
          backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
          middle: const Text('Requests'),
          leading: CupertinoButton(
            onPressed: () => Navigator.of(context).pop(),
            padding: const EdgeInsets.only(left: 10),
            child: Icon(CupertinoIcons.back,
                color: CupertinoTheme.of(context).primaryColor),
          )),
      child: SafeArea(
        child: ListView(
          children: [
            CupertinoListSection(
              children: [
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.person),
                  onTap: () => {
                    Navigator.of(context, rootNavigator: true)
                        .push(CupertinoPageRoute(
                            builder: (context) =>
                                FollowRequestsPage(uuid: widget.uuid)))
                        .then((value) => init())
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Follow Requests'),
                      _numFollowRequests == null
                          ? const SizedBox()
                          : _numFollowRequests! > 0
                              ? Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemRed,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _numFollowRequests.toString(),
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                )
                              : const SizedBox()
                    ],
                  ),
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.person_2_square_stack),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Group Requests'),
                      _numGroupRequests == null
                          ? const SizedBox()
                          : _numGroupRequests! > 0
                              ? Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemRed,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _numGroupRequests.toString(),
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                )
                              : const SizedBox()
                    ],
                  ),
                  onTap: () => {
                    Navigator.of(context, rootNavigator: true)
                        .push(CupertinoPageRoute(
                            builder: (context) =>
                                GroupsRequestsPage(uuid: widget.uuid)))
                        .then((value) => init())
                  },
                ),
                CupertinoListTile(
                  leading: const Icon(CupertinoIcons.calendar_badge_plus),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Event Requests'),
                      _numEventRequests == null
                          ? const SizedBox()
                          : _numEventRequests! > 0
                              ? Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: CupertinoColors.systemRed,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    _numEventRequests.toString(),
                                    style: const TextStyle(
                                      color: CupertinoColors.white,
                                    ),
                                  ),
                                )
                              : const SizedBox()
                    ],
                  ),
                  onTap: () => {
                    Navigator.of(context, rootNavigator: true)
                        .push(CupertinoPageRoute(
                            builder: (context) =>
                                EventsRequestsPage(uuid: widget.uuid)))
                        .then((value) => init())
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
