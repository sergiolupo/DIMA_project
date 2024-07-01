class ArticleModel {
  final String? author;
  final String title;
  final String description;
  final String url;
  final String urlToImage;
  final String content;

  ArticleModel(
      {this.author,
      required this.content,
      required this.description,
      required this.title,
      required this.url,
      required this.urlToImage});
}
