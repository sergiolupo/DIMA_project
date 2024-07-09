import 'package:cached_network_image/cached_network_image.dart';
import 'package:dima_project/pages/news/article_view.dart';
import 'package:flutter/cupertino.dart';

class ShowCategory extends StatelessWidget {
  final String image, description, title, url;
  const ShowCategory(
      {super.key,
      required this.image,
      required this.description,
      required this.title,
      required this.url});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => ArticleView(
                    blogUrl: url,
                    description: description,
                    imageUrl: image,
                    title: title)));
      },
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: CachedNetworkImage(
              imageUrl: image,
              height: 200,
              width: MediaQuery.of(context).size.width,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 5.0),
          Text(
            title,
            maxLines: 2,
            style: const TextStyle(
                color: CupertinoColors.black,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
          Text(
            description,
            maxLines: 3,
          ),
          const SizedBox(height: 20.0),
        ],
      ),
    );
  }
}
