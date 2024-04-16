import 'package:dima_project/models/news/article_model.dart';
import 'package:dima_project/models/news/slider_model.dart';
import 'package:dima_project/services/news_service.dart';
import 'package:dima_project/widgets/news/show_all.dart';
import 'package:flutter/cupertino.dart';

class AllNews extends StatefulWidget {
  final String news;
  const AllNews({super.key, required this.news});

  @override
  State<AllNews> createState() => _AllNewsState();
}

class _AllNewsState extends State<AllNews> {
  List<SliderModel> sliders = [];
  List<ArticleModel> articles = [];
  bool _loadingNews = true, _loadingSliders = true;

  @override
  void initState() {
    getSliders();
    getNews();
    super.initState();
    debugPrint("News: ${widget.news}");
  }

  getNews() async {
    News newsclass = News();
    await newsclass.getNews();
    articles = newsclass.news;
    setState(() {
      _loadingNews = false;
    });
  }

  getSliders() async {
    Sliders slider = Sliders();
    await slider.getSliders();
    sliders = slider.sliders;
    setState(() {
      _loadingSliders = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _loadingSliders || _loadingNews
        ? const CupertinoActivityIndicator(
            radius: 20.0,
          )
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              middle: Text("${widget.news} News",
                  style: const TextStyle(
                      color: CupertinoColors.activeBlue,
                      fontWeight: FontWeight.bold)),
              //centerTitle: true,
              //elevation: 0.0,
            ),
            child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10.0),
                child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: widget.news == "Breaking"
                        ? sliders.length
                        : articles.length,
                    itemBuilder: (context, index) {
                      return ShowAll(
                          url: widget.news == "Breaking"
                              ? sliders[index].url!
                              : articles[index].url!,
                          description: widget.news == "Breaking"
                              ? sliders[index].description!
                              : articles[index].description!,
                          image: widget.news == "Breaking"
                              ? sliders[index].urlToImage!
                              : articles[index].urlToImage!,
                          title: widget.news == "Breaking"
                              ? sliders[index].title!
                              : articles[index].title!);
                    })),
          );
  }
}
