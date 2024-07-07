import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/user_request_tile.dart';
import 'package:flutter/cupertino.dart';

class RequestsPage extends StatefulWidget {
  final String uuid;
  const RequestsPage({super.key, required this.uuid});
  @override
  RequestsPageState createState() => RequestsPageState();
}

class RequestsPageState extends State<RequestsPage> {
  Stream<List<dynamic>>? userRequests;
  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    userRequests = DatabaseService.getFollowRequests(widget.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return userRequests == null
        ? const Center(child: CupertinoActivityIndicator())
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: const Text('Requests'),
              leading: CupertinoButton(
                onPressed: () => Navigator.of(context).pop(),
                padding: const EdgeInsets.only(left: 10),
                child: const Icon(CupertinoIcons.back),
              ),
            ),
            child: SafeArea(
              child: StreamBuilder<List<dynamic>>(
                stream: userRequests,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    final List requests =
                        snapshot.data!.map((doc) => doc).toList();
                    return ListView.builder(
                        itemCount: requests.length,
                        itemBuilder: (context, index) {
                          return StreamBuilder(
                            stream: DatabaseService.getUserDataFromUUID(
                              requests[index],
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                final user = snapshot.data!;
                                return UserRequestTile(
                                    user: user, uuid: widget.uuid);
                              } else {
                                return const Center(
                                  child: CupertinoActivityIndicator(),
                                );
                              }
                            },
                          );
                        });
                  } else {
                    return const Center(
                      child: CupertinoActivityIndicator(),
                    );
                  }
                },
              ),
            ),
          );
  }
}
