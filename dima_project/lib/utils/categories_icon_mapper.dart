import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryIconMapper {
  static List<String> categories = [
    'Environment',
    'Cooking',
    'Culture',
    'Film & TV Series',
    'Books',
    'Gossip',
    'Music',
    'Politics',
    'Health & Wellness',
    'School & Education',
    'Sports',
    'Technology',
    'Volunteering',
  ];

  static iconForCategory(String category) {
    switch (category) {
      case 'Environment':
        return CupertinoIcons.leaf_arrow_circlepath;
      case 'Cooking':
        return FontAwesomeIcons.utensils;
      case 'Culture':
        return CupertinoIcons.globe;
      case 'Film & TV Series':
        return CupertinoIcons.film_fill;
      case 'Books':
        return CupertinoIcons.book;
      case 'Gossip':
        return CupertinoIcons.chat_bubble_2_fill;
      case 'Music':
        return CupertinoIcons.music_note;
      case 'Politics':
        return FontAwesomeIcons.landmark;
      case 'Health & Wellness':
        return CupertinoIcons.heart_fill;
      case 'School & Education':
        return CupertinoIcons.news_solid;
      case 'Sports':
        return CupertinoIcons.sportscourt;
      case 'Technology':
        return CupertinoIcons.device_phone_portrait;
      case 'Volunteering':
        return CupertinoIcons.hand_raised;
      default:
        return CupertinoIcons.question_circle;
    }
  }

  static Widget buildCategoryItem(
      {required String title,
      required IconData icon,
      required onTap,
      required selectedCategories}) {
    final isSelected = selectedCategories.contains(title);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 24.0),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: CupertinoColors.systemGrey4,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(icon),
                const SizedBox(width: 16.0),
                Text(title),
              ],
            ),
            isSelected
                ? const Icon(
                    CupertinoIcons.check_mark_circled_solid,
                    color: CupertinoColors.activeBlue,
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
