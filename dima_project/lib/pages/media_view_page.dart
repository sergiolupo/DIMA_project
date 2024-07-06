import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_project/models/message.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:dima_project/utils/date_util.dart';
import 'package:flutter/cupertino.dart';

class MediaViewPage extends StatefulWidget {
  final Message media;

  const MediaViewPage({super.key, required this.media});

  @override
  MediaViewPageState createState() => MediaViewPageState();
}

class MediaViewPageState extends State<MediaViewPage> {
  Stream<UserData>? _senderStream;

  @override
  void initState() {
    init();
    super.initState();
  }

  void init() {
    _senderStream = DatabaseService.getUserDataFromUUID(widget.media.sender);
  }

  @override
  Widget build(BuildContext context) {
    return _senderStream == null
        ? const Center(child: CupertinoActivityIndicator())
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
                backgroundColor: CupertinoColors.systemPink,
                leading: CupertinoButton(
                  onPressed: () => Navigator.of(context).pop(),
                  padding: const EdgeInsets.only(left: 10),
                  color: CupertinoColors.systemPink,
                  child: const Icon(CupertinoIcons.back,
                      color: CupertinoColors.white),
                )),
            child: SafeArea(
              child: StreamBuilder<UserData>(
                stream: _senderStream,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      color: CupertinoColors.black,
                      child: Stack(
                        children: [
                          Center(
                            child: CachedNetworkImage(
                              imageUrl: widget.media.content,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  const CupertinoActivityIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(CupertinoIcons.photo_fill),
                            ),
                          ),
                          Positioned(
                            top: 20,
                            left: 20,
                            right: 20,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      snapshot.data!.username,
                                      style: const TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 18,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10.0,
                                            color: CupertinoColors.black,
                                            offset: Offset(2.0, 2.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      DateUtil.getFormattedDateAndTime(
                                          context: context,
                                          time: widget
                                              .media.time.microsecondsSinceEpoch
                                              .toString()),
                                      style: const TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 14,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10.0,
                                            color: CupertinoColors.black,
                                            offset: Offset(2.0, 2.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Text(
                                      snapshot.data!.name,
                                      style: const TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 18,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10.0,
                                            color: CupertinoColors.black,
                                            offset: Offset(2.0, 2.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      snapshot.data!.surname,
                                      style: const TextStyle(
                                        color: CupertinoColors.white,
                                        fontSize: 18,
                                        shadows: [
                                          Shadow(
                                            blurRadius: 10.0,
                                            color: CupertinoColors.black,
                                            offset: Offset(2.0, 2.0),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error loading media.'));
                  } else {
                    return const Center(child: CupertinoActivityIndicator());
                  }
                },
              ),
            ),
          );
  }
}
