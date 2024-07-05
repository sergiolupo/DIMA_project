import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/widgets/home/request_tile.dart';
import 'package:flutter/cupertino.dart';

class GroupRequestsPage extends StatefulWidget {
  final String groupId;

  const GroupRequestsPage({
    super.key,
    required this.groupId,
  });

  @override
  GroupRequestsPageState createState() => GroupRequestsPageState();
}

class GroupRequestsPageState extends State<GroupRequestsPage> {
  Stream<List<dynamic>>? requests;
  @override
  void initState() {
    init();
    super.initState();
  }

  init() {
    requests = DatabaseService.getGroupRequests(widget.groupId);
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
        middle: const Text('Group Requests'),
      ),
      child: StreamBuilder<List<dynamic>>(
        stream: requests,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No requests'),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              return StreamBuilder(
                  stream: DatabaseService.getUserDataFromUUID(
                      snapshot.data![index]),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CupertinoActivityIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      final userData = snapshot.data!;
                      return RequestTile(
                        user: userData,
                        groupId: widget.groupId,
                      );
                    }
                  });
            },
          );
        },
      ),
    );
  }
}
