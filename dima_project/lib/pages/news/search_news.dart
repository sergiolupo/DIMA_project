import 'package:dima_project/models/news/article_model.dart';
import 'package:dima_project/services/news_service.dart';
import 'package:dima_project/widgets/news/blog_tile.dart';
import 'package:flutter/cupertino.dart';

class SearchNewsPage extends StatefulWidget {
  const SearchNewsPage({super.key});

  @override
  SearchNewsPageState createState() => SearchNewsPageState();
}

class SearchNewsPageState extends State<SearchNewsPage> {
  final TextEditingController _searchController = TextEditingController();
  Stream<List<ArticleModel>>? _searchResults;

  void _startSearch() {
    setState(() {
      _searchResults = News.getSearchedNews(_searchController.text);
    });
  }

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
        middle: Text(
          "Search News",
          style: TextStyle(color: CupertinoTheme.of(context).primaryColor),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CupertinoSearchTextField(
                controller: _searchController,
                onChanged: (value) => _startSearch(),
              ),
            ),
            Expanded(
              child: StreamBuilder<List<ArticleModel>>(
                stream: _searchResults,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CupertinoActivityIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    if (_searchController.text.isNotEmpty) {
                      return Stack(children: [
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          bottom: MediaQuery.of(context).viewInsets.bottom,
                          child: SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            reverse: false,
                            child: Column(
                              children: [
                                MediaQuery.of(context).platformBrightness ==
                                        Brightness.dark
                                    ? Image.asset(
                                        'assets/darkMode/no_news_found.png',
                                      )
                                    : Image.asset(
                                        'assets/images/no_news_found.png'),
                                const Text("No results found"),
                              ],
                            ),
                          ),
                        )
                      ]);
                    }
                    return Center(
                      child: Column(
                        children: [
                          MediaQuery.of(context).platformBrightness ==
                                  Brightness.dark
                              ? Image.asset('assets/darkMode/search_news.png')
                              : Image.asset('assets/images/search_news.png'),
                          const Text("Search for news"),
                        ],
                      ),
                    );
                  } else {
                    final articles = snapshot.data!;
                    return ListView.builder(
                      itemCount: articles.length,
                      itemBuilder: (context, index) {
                        final article = articles[index];
                        return BlogTile(
                            description: article.description,
                            imageUrl: article.urlToImage,
                            title: article.title,
                            url: article.url);
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
