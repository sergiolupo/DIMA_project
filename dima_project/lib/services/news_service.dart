import 'dart:async';

import 'package:dima_project/models/category_model.dart';
import 'package:dima_project/utils/category_util.dart';
import 'package:dima_project/models/article_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class News {
  List<ArticleModel> news = [];
  List<ArticleModel> categories = [];
  List<ArticleModel> sliders = [];

  Future<void> getNews() async {
    String url =
        "https://newsapi.org/v2/top-headlines?sources=bbc-news&apiKey=61f777e67a9346cebb7cecf45b243af9";
    var response = await http.get(Uri.parse(url));

    var jsonData = jsonDecode(response.body);

    if (jsonData['status'] == 'ok') {
      jsonData["articles"].forEach((element) {
        if (element["title"] != null &&
            element['description'] != null &&
            element['url'] != null &&
            element['urlToImage'] != null) {
          ArticleModel articleModel = ArticleModel(
            title: element["title"],
            description: element["description"],
            url: element["url"],
            urlToImage: element["urlToImage"],
          );
          news.add(articleModel);
        }
      });
    }
  }

  Future<void> getCategoriesNews(String category) async {
    String url =
        "https://newsapi.org/v2/everything?q=$category&apiKey=61f777e67a9346cebb7cecf45b243af9";
    var response = await http.get(Uri.parse(url));

    var jsonData = jsonDecode(response.body);

    if (jsonData['status'] == 'ok') {
      jsonData["articles"].forEach((element) {
        if (element["title"] != null &&
            element['description'] != null &&
            element['url'] != null &&
            element['urlToImage'] != null) {
          ArticleModel showCategoryModel = ArticleModel(
            title: element["title"],
            description: element["description"],
            url: element["url"],
            urlToImage: element["urlToImage"],
          );
          categories.add(showCategoryModel);
        }
      });
    }
  }

  Future<void> getSliders() async {
    String url =
        "https://newsapi.org/v2/top-headlines?sources=fox-news&apiKey=61f777e67a9346cebb7cecf45b243af9";
    var response = await http.get(Uri.parse(url));

    var jsonData = jsonDecode(response.body);

    if (jsonData['status'] == 'ok') {
      jsonData["articles"].forEach((element) {
        if (element["title"] != null &&
            element['description'] != null &&
            element['url'] != null &&
            element['urlToImage'] != null) {
          ArticleModel sliderModel = ArticleModel(
            title: element["title"],
            description: element["description"],
            url: element["url"],
            urlToImage: element["urlToImage"],
          );
          sliders.add(sliderModel);
        }
      });
    }
  }

  static List<CategoryModel> getCategories(List<String> userCategories) {
    List<CategoryModel> categories = [];

    for (String category in userCategories) {
      categories.add(CategoryUtil.getCategoryModel(category));
    }

    return categories;
  }

  static Stream<List<ArticleModel>> getSearchedNews(String search) async* {
    List<ArticleModel> news = [];

    String url =
        "https://newsapi.org/v2/everything?q=$search&apiKey=61f777e67a9346cebb7cecf45b243af9";
    var response = await http.get(Uri.parse(url));

    var jsonData = jsonDecode(response.body);

    if (jsonData['status'] == 'ok') {
      jsonData["articles"].forEach((element) {
        if (element["title"] != null &&
            element['description'] != null &&
            element['url'] != null &&
            element['urlToImage'] != null) {
          ArticleModel articleModel = ArticleModel(
            title: element["title"],
            description: element["description"],
            url: element["url"],
            urlToImage: element["urlToImage"],
          );
          news.add(articleModel);
        }
      });
    }
    yield news;
  }
}
