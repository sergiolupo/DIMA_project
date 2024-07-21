import 'package:dima_project/pages/userprofile_page.dart';
import 'package:dima_project/pages/userprofile_tablet_page.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';

class ResponsiveUserprofile extends StatelessWidget {
  final String uuid;
  final String user;

  @override
  const ResponsiveUserprofile(
      {super.key, required this.uuid, required this.user});

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > Constants.limitWidth) {
      return UserProfileTablet(user: user, uuid: uuid);
    } else {
      return UserProfile(
        user: user,
        uuid: uuid,
      );
    }
  }
}
