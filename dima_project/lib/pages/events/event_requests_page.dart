import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:dima_project/widgets/create_image_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventRequestsPage extends ConsumerStatefulWidget {
  final List<String> requests;
  final DatabaseService databaseService;
  final String eventId;
  final String detailId;
  const EventRequestsPage({
    super.key,
    required this.requests,
    required this.databaseService,
    required this.eventId,
    required this.detailId,
  });

  @override
  EventRequestsPageState createState() => EventRequestsPageState();
}

class EventRequestsPageState extends ConsumerState<EventRequestsPage> {
  late final DatabaseService _databaseService;
  List<String> requests = [];
  @override
  void initState() {
    _databaseService = widget.databaseService;
    requests = widget.requests;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<AsyncValue<UserData>> users = [];
    for (var user in widget.requests) {
      users.add(ref.watch(userProvider(user)));
    }
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          child: const Icon(CupertinoIcons.back),
          onPressed: () {
            ref.invalidate(eventProvider(widget.eventId));
            Navigator.of(context).pop();
          },
        ),
        middle: Text(
          'Event Requests',
          style: TextStyle(color: CupertinoTheme.of(context).primaryColor),
        ),
      ),
      child: requests.isEmpty
          ? Center(
              child: Column(
                children: [
                  SizedBox(
                    height:
                        MediaQuery.of(context).size.width > Constants.limitWidth
                            ? 600
                            : 400,
                    child:
                        CupertinoTheme.of(context).brightness == Brightness.dark
                            ? Image.asset(
                                "assets/darkMode/no_event_requests.png",
                                fit: BoxFit.contain,
                              )
                            : Image.asset(
                                "assets/images/no_event_requests.png",
                                fit: BoxFit.contain,
                              ),
                  ),
                  const Text("No event requests",
                      style: TextStyle(
                          color: CupertinoColors.systemGrey2,
                          fontWeight: FontWeight.bold,
                          fontSize: 20)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: requests.length,
              itemBuilder: (context, index) {
                final userData = users[index];
                return userData.when(
                    loading: () => const SizedBox.shrink(),
                    error: (error, stack) => const Text("Error"),
                    data: (user) {
                      return Row(
                        children: [
                          Expanded(
                            child: CupertinoListTile(
                              leading: ClipOval(
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  color: CupertinoColors.lightBackgroundGray,
                                  child: CreateImageWidget.getUserImage(
                                      user.imagePath!, 1),
                                ),
                              ),
                              title: Text(
                                user.username,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text("${user.name} ${user.surname}"),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              try {
                                await _databaseService.acceptEventRequest(
                                    widget.eventId, widget.detailId, user.uid!);
                                ref.invalidate(eventProvider(widget.eventId));
                                ref.invalidate(joinedEventsProvider(user.uid!));
                                ref.invalidate(
                                    createdEventsProvider(AuthService.uid));
                              } catch (error) {
                                debugPrint(error.toString());
                                if (!context.mounted) return;
                                showCupertinoDialog(
                                    context: context,
                                    builder: (context) {
                                      return CupertinoAlertDialog(
                                        title: const Text("Error"),
                                        content: const Text(
                                            "User deleted his account"),
                                        actions: [
                                          CupertinoDialogAction(
                                            child: const Text("Ok"),
                                            onPressed: () =>
                                                Navigator.of(context).pop(),
                                          ),
                                        ],
                                      );
                                    });
                              }
                              setState(() {
                                requests.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.only(right: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: const Text(
                                  "Accept",
                                  style:
                                      TextStyle(color: CupertinoColors.white),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              await _databaseService.denyEventRequest(
                                  widget.eventId, widget.detailId, user.uid!);
                              ref.invalidate(eventProvider(widget.eventId));

                              setState(() {
                                requests.removeAt(index);
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.only(right: 20),
                              child: Container(
                                decoration: BoxDecoration(
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                child: const Text(
                                  "Deny",
                                  style:
                                      TextStyle(color: CupertinoColors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    });
              },
            ),
    );
  }
}
