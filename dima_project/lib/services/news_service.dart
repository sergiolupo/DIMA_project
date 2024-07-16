import 'dart:async';

import 'package:dima_project/models/news/category_model.dart';
import 'package:dima_project/utils/categories_icon_mapper.dart';
import 'package:dima_project/models/news/article_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class News {
  List<ArticleModel> news = [];
  List<ArticleModel> categories = [];
  List<ArticleModel> sliders = [];

  Future<void> getNews() async {
    String url =
        "https://newsapi.org/v2/top-headlines?country=us&apiKey=61f777e67a9346cebb7cecf45b243af9";
    var response = await http.get(Uri.parse(url));

    var jsonData = jsonDecode(response.body);

    if (jsonData['status'] == 'ok') {
      jsonData["articles"].forEach((element) {
        if (element["title"] != null &&
            element['description'] != null &&
            element['url'] != null &&
            element['urlToImage'] != null &&
            element['content'] != null &&
            element['author'] != null) {
          ArticleModel articleModel = ArticleModel(
              title: element["title"],
              description: element["description"],
              url: element["url"],
              urlToImage: element["urlToImage"],
              content: element["content"],
              author: element["author"]);
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
            element['urlToImage'] != null &&
            element['content'] != null &&
            element['author'] != null) {
          ArticleModel showCategoryModel = ArticleModel(
              title: element["title"],
              description: element["description"],
              url: element["url"],
              urlToImage: element["urlToImage"],
              content: element["content"],
              author: element["author"]);
          categories.add(showCategoryModel);
        }
      });
    }
  }

  Future<void> getSliders() async {
    String url =
        "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=61f777e67a9346cebb7cecf45b243af9";
    var response = await http.get(Uri.parse(url));

    var jsonData = jsonDecode(response.body);

    if (jsonData['status'] == 'ok') {
      jsonData["articles"].forEach((element) {
        if (element["title"] != null &&
            element['description'] != null &&
            element['url'] != null &&
            element['urlToImage'] != null &&
            element['content'] != null &&
            element['author'] != null) {
          ArticleModel sliderModel = ArticleModel(
              title: element["title"],
              description: element["description"],
              url: element["url"],
              urlToImage: element["urlToImage"],
              content: element["content"],
              author: element["author"]);
          sliders.add(sliderModel);
        }
      });
    }
  }

  static List<CategoryModel> getCategories(List<String> userCategories) {
    List<CategoryModel> categories = [];

    for (String category in userCategories) {
      categories.add(CategoryIconMapper.getCategoryModel(category));
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
            element['urlToImage'] != null &&
            element['content'] != null &&
            element['author'] != null) {
          ArticleModel articleModel = ArticleModel(
            title: element["title"],
            description: element["description"],
            url: element["url"],
            urlToImage: element["urlToImage"],
            content: element["content"],
            author: element[
                "author"], // Assuming you have an author field in the ArticleModel
          );
          news.add(articleModel);
        }
      });
    }
    yield news; // Emit the list of articles
  }
}
