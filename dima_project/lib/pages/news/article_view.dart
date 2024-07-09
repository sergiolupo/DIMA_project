import 'package:dima_project/pages/news/share_news_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleView extends StatefulWidget {
  final String blogUrl;

  const ArticleView({super.key, required this.blogUrl});

  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {
  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("AGOR"),
              Text("APP",
                  style: TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontWeight: FontWeight.bold))
            ],
          ),
          trailing: GestureDetector(
            child: const Icon(CupertinoIcons.share),
            onTap: () {
              Navigator.of(context).push(CupertinoPageRoute(
                  builder: (context) => ShareNewsPage(
                      uuid: FirebaseAuth.instance.currentUser!.uid,
                      blogUrl: widget.blogUrl)));
            },
          ),
        ),
        child: WebView(
          initialUrl: widget.blogUrl,
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
