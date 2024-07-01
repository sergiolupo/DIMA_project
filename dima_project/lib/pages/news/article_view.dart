import 'package:flutter/cupertino.dart';
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
        navigationBar: const CupertinoNavigationBar(
          middle: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("AGOR"),
              Text("APP",
                  style: TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontWeight: FontWeight.bold))
            ],
          ),
        ),
        child: WebView(
          initialUrl: widget.blogUrl,
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
