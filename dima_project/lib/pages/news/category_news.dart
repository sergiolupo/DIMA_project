import 'package:dima_project/models/news/article_model.dart';
import 'package:dima_project/services/news_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/widgets/news/show_category.dart';

class CategoryNews extends StatefulWidget {
  final String name;
  const CategoryNews({super.key, required this.name});
  @override
  State<CategoryNews> createState() => _CategoryNewsState();
}

class _CategoryNewsState extends State<CategoryNews> {
  List<ArticleModel> categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    getCategories();
  }

  getCategories() async {
    News showCategoryNews = News();
    await showCategoryNews.getCategoriesNews(widget.name.toLowerCase());
    categories = showCategoryNews.categories;
    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const CupertinoActivityIndicator()
        : CupertinoPageScaffold(
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
                widget.name,
                style: TextStyle(
                    color: CupertinoTheme.of(context).primaryColor,
                    fontWeight: FontWeight.bold),
              ),
            ),
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      return ShowCategory(
                          url: categories[index].url,
                          description: categories[index].description,
                          image: categories[index].urlToImage,
                          title: categories[index].title);
                    })));
  }
}
