import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/show_event.dart';
import 'package:dima_project/pages/show_event_tablet.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';

class ResponsiveShowEvent extends StatelessWidget {
  final String uuid;
  final String eventId;
  final UserData userData;
  final bool createdEvents;

  @override
  const ResponsiveShowEvent(
      {super.key,
      required this.uuid,
      required this.eventId,
      required this.userData,
      required this.createdEvents});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > Constants.limitWidth) {
      return ShowEventTablet(
        uuid: uuid,
        eventId: eventId,
        userData: userData,
        createdEvents: createdEvents,
      );
    } else {
      return ShowEvent(
        uuid: uuid,
        eventId: eventId,
        userData: userData,
        createdEvents: createdEvents,
      );
    }
  }
}
