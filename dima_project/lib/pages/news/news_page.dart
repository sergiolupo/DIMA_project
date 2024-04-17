import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_project/models/user.dart';
import 'package:dima_project/pages/news/all_news.dart';
import 'package:dima_project/pages/news/article_view.dart';
import 'package:dima_project/services/news_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/models/news/category_model.dart';
import 'package:dima_project/models/news/slider_model.dart';
import 'package:dima_project/models/news/article_model.dart';
import 'package:dima_project/widgets/news/category_tile.dart';
import 'package:dima_project/widgets/news/blog_tile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class NewsPage extends StatefulWidget {
  final UserData user;
  const NewsPage({super.key, required this.user});

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  List<CategoryModel> categories = [];
  List<SliderModel> sliders = [];
  List<ArticleModel> articles = [];

  bool _loading = true;
  int activeIndex = 0;

  @override
  void initState() {
    categories = getCategories(widget.user.categories);
    getSliders();
    getNews();
    super.initState();
  }

  getNews() async {
    News newsclass = News();
    await newsclass.getNews();
    setState(() {
      articles = newsclass.news;
      _loading = false;
    });
  }

  getSliders() async {
    Sliders slider = Sliders();
    await slider.getSliders();
    setState(() {
      sliders = slider.sliders;
    });
  }

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
      child: _loading
          ? const Center(child: CupertinoActivityIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      height: 70,
                      child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: categories.length,
                          itemBuilder: (context, index) {
                            return CategoryTile(
                              image: categories[index].image,
                              categoryName: categories[index].categoryName,
                            );
                          }),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Breaking News",
                            style: TextStyle(
                                color: CupertinoColors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => const AllNews(
                                            news: "Breaking",
                                          )));
                            },
                            child: const Text(
                              "View All",
                              style: TextStyle(
                                  color: CupertinoColors.activeBlue,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(
                      height: 20.0,
                    ),
                    CarouselSlider.builder(
                        itemCount:
                            5, //it's arbitrary, we can put sliders.length (that is 10 for this api)
                        itemBuilder: (context, index, realIndex) {
                          String? res = sliders[index].urlToImage;
                          String? res1 = sliders[index].title;
                          return buildImage(res!, index, res1!);
                        },
                        options: CarouselOptions(
                            height: 200,
                            autoPlay: true,
                            enlargeCenterPage: false,
                            enlargeStrategy: CenterPageEnlargeStrategy.height,
                            onPageChanged: (index, reason) {
                              setState(() {
                                activeIndex = index;
                              });
                            })),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Center(
                      child: buildIndicator(),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Trending News",
                            style: TextStyle(
                                color: CupertinoColors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => const AllNews(
                                          news: "Trending",
                                        ))),
                            child: const Text(
                              "View All",
                              style: TextStyle(
                                  color: CupertinoColors.activeBlue,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 16.0),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10.0),
                    ListView.builder(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemCount: articles.length,
                        itemBuilder: (context, index) {
                          return BlogTile(
                              url: articles[index].url!,
                              description: articles[index].description!,
                              imageUrl: articles[index].urlToImage!,
                              title: articles[index].title!);
                        })
                  ],
                ),
              ),
            ),
    );
  }

  //carousel slider
  Widget buildImage(String image, int index, String name) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) =>
                        ArticleView(blogUrl: sliders[index].url!)));
          },
          child: Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular((10)),
              child: CachedNetworkImage(
                imageUrl: image,
                height: 250.0,
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
              ),
            ),
            Container(
              height: 250,
              padding: const EdgeInsets.only(left: 10.0),
              margin: const EdgeInsets.only(top: 150),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: CupertinoColors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              child: Text(
                name,
                maxLines: 2,
                style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
            )
          ]),
        ),
      );

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: 5, //we can put sliders.length
        effect: const SlideEffect(
            dotWidth: 15,
            dotHeight: 15,
            activeDotColor: CupertinoColors.activeBlue),
      );
}
