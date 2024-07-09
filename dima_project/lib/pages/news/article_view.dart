import 'package:dima_project/pages/news/share_news_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleView extends StatefulWidget {
  final String description, imageUrl, title, blogUrl;
  const ArticleView(
      {super.key,
      required this.blogUrl,
      required this.description,
      required this.imageUrl,
      required this.title});

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
            onTap: () async {
              final ids = await Navigator.of(context, rootNavigator: true)
                  .push(CupertinoPageRoute(
                      builder: (context) => ShareNewsPage(
                            uuid: FirebaseAuth.instance.currentUser!.uid,
                          )));
              if (ids is Map && ids['groups'].isNotEmpty) {
                for (var id in ids['groups']) {
                  await DatabaseService.shareNews(widget.title,
                      widget.description, widget.imageUrl, widget.blogUrl, id);
                }
              }
            },
          ),
        ),
        child: WebView(
          initialUrl: widget.blogUrl,
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
