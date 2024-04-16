import 'package:dima_project/models/news/category_model.dart';
import 'package:dima_project/utils/categories_icon_mapper.dart';
import 'package:dima_project/models/news/article_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dima_project/models/news/show_category.dart';
import 'package:dima_project/models/news/slider_model.dart';

List<CategoryModel> getCategories(List<String> userCategories) {
  List<CategoryModel> categories = [];

  for (String category in userCategories) {
    categories.add(CategoryIconMapper.getCategoryModel(category));
  }

  return categories;
}

class News {
  List<ArticleModel> news = [];

  Future<void> getNews() async {
    String url =
        "https://newsapi.org/v2/everything?q=israele&from=2024-04-02&sortBy=publishedAt&apiKey=b0c96299b05f4084a3b2cf516e2d775d";
    var response = await http.get(Uri.parse(url));

    var jsonData = jsonDecode(response.body);

    if (jsonData['status'] == 'ok') {
      jsonData["articles"].forEach((element) {
        if (element["urlToImage"] != null && element['description'] != null) {
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
}

class ShowCategoryNews {
  List<ShowCategoryModel> categories = [];

  Future<void> getCategoriesNews(String category) async {
    String url =
        "https://newsapi.org/v2/top-headlines?country=us&category=$category&apiKey=b0c96299b05f4084a3b2cf516e2d775d";
    var response = await http.get(Uri.parse(url));

    var jsonData = jsonDecode(response.body);

    if (jsonData['status'] == 'ok') {
      jsonData["articles"].forEach((element) {
        if (element["urlToImage"] != null && element['description'] != null) {
          ShowCategoryModel showCategoryModel = ShowCategoryModel(
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
}

class Sliders {
  List<SliderModel> sliders = [];

  Future<void> getSliders() async {
    String url =
        "https://newsapi.org/v2/top-headlines?sources=techcrunch&apiKey=b0c96299b05f4084a3b2cf516e2d775d";
    var response = await http.get(Uri.parse(url));

    var jsonData = jsonDecode(response.body);

    if (jsonData['status'] == 'ok') {
      jsonData["articles"].forEach((element) {
        if (element["urlToImage"] != null && element['description'] != null) {
          SliderModel sliderModel = SliderModel(
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
}
