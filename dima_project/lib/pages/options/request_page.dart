import 'package:dima_project/models/group.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/options/follow_requests_page.dart';
import 'package:dima_project/pages/options/groups_requests_page.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:flutter/cupertino.dart';

class ShowRequestPage extends StatefulWidget {
  const ShowRequestPage({
    super.key,
  });
  @override
  ShowRequestPageState createState() => ShowRequestPageState();
}

class ShowRequestPageState extends State<ShowRequestPage> {
  List<UserData>? _followRequests;
  List<Group>? _groupRequests;
  final String uid = AuthService.uid;
  final DatabaseService _databaseService = DatabaseService();
  @override
  void initState() {
    init();
    super.initState();
  }

  init() async {
    List<UserData>? followRequests;
    List<Group>? groupRequests;
    followRequests = (await _databaseService.getFollowRequests(uid));
    setState(() {
      _followRequests = followRequests;
    });
    groupRequests = (await _databaseService.getUserGroupRequests(uid));
    setState(() {
      _groupRequests = groupRequests;
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
                            builder: (context) => FollowRequestsPage(
                                  followRequests: _followRequests!,
                                )))
                        .then((value) => init())
                  },
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Follow Requests'),
                      _followRequests == null
                          ? const SizedBox()
                          : _followRequests!.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                  ),
                                  child: Text(
                                    _followRequests!.length.toString(),
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
                      _groupRequests == null
                          ? const SizedBox()
                          : _groupRequests!.isNotEmpty
                              ? Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color:
                                        CupertinoTheme.of(context).primaryColor,
                                  ),
                                  child: Text(
                                    _groupRequests!.length.toString(),
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
                            builder: (context) => GroupsRequestsPage(
                                groupRequests: _groupRequests!)))
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
