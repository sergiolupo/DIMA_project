import 'package:dima_project/models/event.dart';
import 'package:flutter/cupertino.dart';

class ShowEvent extends StatefulWidget {
  final String uuid;
  final Event event;
  final int isJoined; // 0 is not joined, 1 is joined, 2 is requested

  const ShowEvent({
    super.key,
    required this.uuid,
    required this.event,
    required this.isJoined,
  });

  @override
  ShowEventState createState() => ShowEventState();
}

class ShowEventState extends State<ShowEvent> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        backgroundColor: CupertinoColors.systemPink,
        leading: CupertinoNavigationBarBackButton(
          color: CupertinoColors.white,
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      child: Container(
        color: CupertinoColors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stack centered horizontally
            Center(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  // Conditional rendering of the event image
                  Container(
                    width: 400,
                    height: 400,
                    color: CupertinoColors.white,
                    child: (widget.event.imagePath != null &&
                            widget.event.imagePath!.isNotEmpty)
                        ? Image.network(
                            widget.event.imagePath!,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            'assets/default_event_image.png',
                            fit: BoxFit.cover,
                          ),
                  ),
                  // Join Event button
                  Container(
                    margin: const EdgeInsets.only(top: 370),
                    width: 400,
                    child: CupertinoButton.filled(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      borderRadius: BorderRadius.zero,
                      onPressed: () {
                        // Handle button press
                      },
                      child: const Text(
                        'Join Event',
                        style: TextStyle(
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
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0),
            // Event name
            Text(
              widget.event.name,
              textAlign: TextAlign.start,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: CupertinoColors.black,
              ),
            ),
            const SizedBox(height: 10.0),
            // Event description
            Text(
              widget.event.description,
              style: const TextStyle(
                fontSize: 18,
                color: CupertinoColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
