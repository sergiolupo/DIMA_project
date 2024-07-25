import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_project/pages/news/all_news.dart';
import 'package:dima_project/pages/news/article_view.dart';
import 'package:dima_project/pages/news/search_news.dart';
import 'package:dima_project/services/auth_service.dart';
import 'package:dima_project/services/news_service.dart';
import 'package:dima_project/services/provider_service.dart';
import 'package:dima_project/utils/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:dima_project/models/news/article_model.dart';
import 'package:dima_project/widgets/news/category_tile.dart';
import 'package:dima_project/widgets/news/blog_tile.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class NewsPage extends ConsumerStatefulWidget {
  const NewsPage({
    super.key,
  });

  @override
  NewsPageState createState() => NewsPageState();
}

class NewsPageState extends ConsumerState<NewsPage> {
  List<ArticleModel>? sliders;
  List<ArticleModel>? articles;
  News news = News();

  int numberOfNews =
      6; //it's arbitrary, we can put sliders.length (that is 10 for this api)
  int activeIndex = 0;
  final String uid = AuthService.uid;
  @override
  void initState() {
    ref.read(userProvider(uid));
    getSliders();
    getNews();
    super.initState();
  }

  getNews() async {
    await news.getNews();
    setState(() {
      articles = news.news;
    });
  }

  getSliders() async {
    await news.getSliders();
    setState(() {
      sliders = news.sliders;
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider(uid));

    return sliders == null || articles == null
        ? const CupertinoActivityIndicator()
        : CupertinoPageScaffold(
            navigationBar: CupertinoNavigationBar(
              transitionBetweenRoutes: false,
              trailing: GestureDetector(
                onTap: () {
                  Navigator.push(
                      context,
                      CupertinoPageRoute(
                          builder: (context) => const SearchNewsPage()));
                },
                child: Icon(
                  CupertinoIcons.search,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
              ),
              middle: Text(
                "News",
                style: TextStyle(
                  fontSize: 25.0,
                  fontWeight: FontWeight.bold,
                  color: CupertinoTheme.of(context).primaryColor,
                ),
              ),
              backgroundColor: CupertinoTheme.of(context).barBackgroundColor,
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20.0),
                    Container(
                      margin: const EdgeInsets.only(left: 10.0),
                      height: MediaQuery.of(context).size.width >
                              Constants.limitWidth
                          ? 140
                          : 70,
                      child: user.when(
                          data: (user) {
                            final List<String> categories = user.categories;
                            final newsCategories =
                                News.getCategories(categories);
                            return ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: categories.length,
                                itemBuilder: (context, index) {
                                  return CategoryTile(
                                    image: newsCategories[index].image,
                                    categoryName:
                                        newsCategories[index].categoryName,
                                  );
                                });
                          },
                          loading: () => const CupertinoActivityIndicator(),
                          error: (error, _) => Text('Error: $error')),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Breaking News",
                            style: TextStyle(
                                color: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle
                                    .color,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                      builder: (context) => AllNews(
                                            news: "Breaking",
                                            articles: sliders!
                                                .sublist(0, numberOfNews),
                                          )));
                            },
                            child: Text(
                              "View All",
                              style: TextStyle(
                                color: CupertinoTheme.of(context).primaryColor,
                                fontWeight: FontWeight.w500,
                                fontSize: 16.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    CarouselSlider.builder(
                        itemCount: numberOfNews,
                        itemBuilder: (context, index, realIndex) {
                          String? image = sliders![index].urlToImage;
                          String? title = sliders![index].title;
                          return buildNews(image, index, title);
                        },
                        options: CarouselOptions(
                            height: MediaQuery.of(context).size.width >
                                    Constants.limitWidth
                                ? 400
                                : 200,
                            autoPlay: true,
                            enlargeCenterPage: false,
                            enlargeStrategy: CenterPageEnlargeStrategy.height,
                            onPageChanged: (index, reason) {
                              setState(() {
                                activeIndex = index;
                              });
                            })),
                    const SizedBox(height: 30.0),
                    Center(
                      child: buildIndicator(),
                    ),
                    const SizedBox(
                      height: 30.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Trending News",
                            style: TextStyle(
                                color: CupertinoTheme.of(context)
                                    .textTheme
                                    .textStyle
                                    .color,
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                    builder: (context) => AllNews(
                                        news: "Trending",
                                        articles: articles!))),
                            child: Text(
                              "View All",
                              style: TextStyle(
                                  color:
                                      CupertinoTheme.of(context).primaryColor,
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
                        itemCount: articles!.length,
                        itemBuilder: (context, index) {
                          return BlogTile(
                              url: articles![index].url,
                              description: articles![index].description,
                              imageUrl: articles![index].urlToImage,
                              title: articles![index].title);
                        })
                  ],
                ),
              ),
            ),
          );
  }

  //carousel slider
  Widget buildNews(String image, int index, String name) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 5.0),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                CupertinoPageRoute(
                    builder: (context) => ArticleView(
                        blogUrl: sliders![index].url,
                        description: sliders![index].description,
                        imageUrl: sliders![index].urlToImage,
                        title: sliders![index].title)));
          },
          child: Stack(children: [
            ClipRRect(
              borderRadius: BorderRadius.circular((10)),
              child: CachedNetworkImage(
                imageUrl: image,
                height: MediaQuery.of(context).size.width,
                /*MediaQuery.of(context).size.width > Constants.limitWidth
                    ? 300
                    : 250.0,*/
                fit: BoxFit.cover,
                width: MediaQuery.of(context).size.width,
                alignment: Alignment.topCenter,
              ),
            ),
            Container(
              height: MediaQuery.of(context).size.width,
              /*MediaQuery.of(context).size.width > Constants.limitWidth
                  ? 300
                  : 250,*/
              padding: const EdgeInsets.only(left: 10.0),
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).size.width > Constants.limitWidth
                      ? 350
                      : 150),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                  color: CupertinoColors.black.withOpacity(0.5),
                  borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10))),
              child: Text(
                name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
      count: numberOfNews,
      effect: SlideEffect(
        dotWidth: 15,
        dotHeight: 15,
        activeDotColor: CupertinoTheme.of(context).primaryColor,
      ));
}
