import 'package:dima_project/pages/news/category_news.dart';
import 'package:flutter/cupertino.dart';

class CategoryTile extends StatelessWidget {
  final String categoryName;
  final String image;
  const CategoryTile(
      {super.key, required this.image, required this.categoryName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            CupertinoPageRoute(
                builder: (context) => CategoryNews(name: categoryName)));
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Stack(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.asset(
                  image,
                  width: 120,
                  height: 70,
                  fit: BoxFit.cover,
                )),
            Container(
                width: 120,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: const Color.fromRGBO(0, 0, 0, 0.34),
                ),
                child: Text(categoryName,
                    style: const TextStyle(
                        color: CupertinoColors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500)))
          ],
        ),
      ),
    );
  }
}
