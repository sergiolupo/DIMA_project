import 'package:flutter/cupertino.dart';

class CategorySelectionForm extends StatefulWidget {
  final List<String>? selectedCategories;
  const CategorySelectionForm({super.key, this.selectedCategories});
  @override
  CategorySelectionFormState createState() => CategorySelectionFormState();
}

class CategorySelectionFormState extends State<CategorySelectionForm> {
  late List<String> selectedCategories;

  @override
  void initState() {
    super.initState();
    selectedCategories = widget.selectedCategories ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            buildCategoryItem(
              title: 'Environment',
              icon: CupertinoIcons.leaf_arrow_circlepath,
            ),
            buildCategoryItem(
              title: 'Cooking',
              icon: CupertinoIcons.bolt_fill,
            ),
            buildCategoryItem(
              title: 'Culture',
              icon: CupertinoIcons.globe,
            ),
            buildCategoryItem(
              title: 'Film & TV Series',
              icon: CupertinoIcons.film_fill,
            ),
            buildCategoryItem(
              title: 'Books',
              icon: CupertinoIcons.book,
            ),
            buildCategoryItem(
              title: 'Gossip',
              icon: CupertinoIcons.chat_bubble_2_fill,
            ),
            buildCategoryItem(
              title: 'Music',
              icon: CupertinoIcons.music_note,
            ),
            buildCategoryItem(
              title: 'Politics',
              icon: CupertinoIcons.person_2_square_stack_fill,
            ),
            buildCategoryItem(
              title: 'Health & Wellness',
              icon: CupertinoIcons.heart_fill,
            ),
            buildCategoryItem(
                title: 'School & Education', icon: CupertinoIcons.news),
            buildCategoryItem(
                title: 'Sports', icon: CupertinoIcons.sportscourt),
            buildCategoryItem(
                title: 'Technology',
                icon: CupertinoIcons.device_phone_portrait),
            buildCategoryItem(
                title: 'Volunteering', icon: CupertinoIcons.hand_raised),
          ],
        ),
      ),
    );
  }

  Widget buildCategoryItem({required String title, required IconData icon}) {
    final isSelected = selectedCategories.contains(title);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            selectedCategories.remove(title);
          } else {
            selectedCategories.add(title);
          }
        });
      },
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

  @override
  void dispose() {
    super.dispose();
  }
}
