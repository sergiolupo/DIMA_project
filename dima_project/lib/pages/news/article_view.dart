import 'package:dima_project/pages/news/share_news_page.dart';
import 'package:dima_project/services/database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ArticleView extends StatelessWidget {
  final String description, imageUrl, title, blogUrl;
  const ArticleView(
      {super.key,
      required this.blogUrl,
      required this.description,
      required this.imageUrl,
      required this.title});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          leading: Navigator.canPop(context)
              ? CupertinoNavigationBarBackButton(
                  color: CupertinoTheme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )
              : null,
          trailing: GestureDetector(
            child: const Icon(CupertinoIcons.share),
            onTap: () async {
              final ids = await Navigator.of(context, rootNavigator: true).push(
                  CupertinoPageRoute(
                      builder: (context) => const ShareNewsPage()));
              if (ids is Map && ids['groups'].isNotEmpty) {
                for (var id in ids['groups']) {
                  await DatabaseService.shareNewsOnGroups(
                      title, description, imageUrl, blogUrl, id);
                }
              }
              if (ids is Map && ids['users'].isNotEmpty) {
                for (var id in ids['users']) {
                  await DatabaseService.shareNewsOnFollower(
                      title, description, imageUrl, blogUrl, id);
                }
              }
            },
          ),
        ),
        child: WebView(
          initialUrl: blogUrl,
          javascriptMode: JavascriptMode.unrestricted,
        ));
  }
}
