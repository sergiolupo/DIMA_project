import 'package:flutter/cupertino.dart';

class DeletedAccountPage extends StatelessWidget {
  const DeletedAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      color: CupertinoTheme.of(context).scaffoldBackgroundColor,
      child: SizedBox(
          width: MediaQuery.of(context).size.width,
          child: MediaQuery.of(context).platformBrightness == Brightness.dark
              ? Image.asset('assets/darkMode/account_canceled.png')
              : Image.asset('assets/images/account_canceled.png')),
    );
  }
}
