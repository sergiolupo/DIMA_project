import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CategoryIconMapper {
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
}
