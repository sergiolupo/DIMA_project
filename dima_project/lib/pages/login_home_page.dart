import 'package:dima_project/pages/home_page.dart';
import 'package:dima_project/pages/login_page.dart';
import 'package:dima_project/utils/helper_functions.dart';
import 'package:flutter/cupertino.dart';

class LoginHomePage extends StatefulWidget {
  const LoginHomePage({super.key});

  @override
  LoginHomePageState createState() => LoginHomePageState();
}

class LoginHomePageState extends State<LoginHomePage> {
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    //getUserStatuts();
  }

  getUserStatuts() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if (value != null) {
        setState(() {
          _isSignedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isSignedIn ? const HomePage() : const LoginPage();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
