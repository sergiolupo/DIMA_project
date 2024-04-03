import 'package:flutter/cupertino.dart';
import 'package:dima_project/models/categories.dart';

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
    return Column(
      children: <Widget>[
        buildCategoryItem(
          title: 'Environment',
          icon: CategoryIconMapper.iconForCategory('Environment'),
        ),
        buildCategoryItem(
          title: 'Cooking',
          icon: CategoryIconMapper.iconForCategory('Cooking'),
        ),
        buildCategoryItem(
          title: 'Culture',
          icon: CategoryIconMapper.iconForCategory('Culture'),
        ),
        buildCategoryItem(
          title: 'Film & TV Series',
          icon: CategoryIconMapper.iconForCategory('Film & TV Series'),
        ),
        buildCategoryItem(
          title: 'Books',
          icon: CategoryIconMapper.iconForCategory('Books'),
        ),
        buildCategoryItem(
          title: 'Gossip',
          icon: CategoryIconMapper.iconForCategory('Gossip'),
        ),
        buildCategoryItem(
          title: 'Music',
          icon: CategoryIconMapper.iconForCategory('Music'),
        ),
        buildCategoryItem(
          title: 'Politics',
          icon: CategoryIconMapper.iconForCategory('Politics'),
        ),
        buildCategoryItem(
          title: 'Health & Wellness',
          icon: CategoryIconMapper.iconForCategory('Health & Wellness'),
        ),
        buildCategoryItem(
            title: 'School & Education',
            icon: CategoryIconMapper.iconForCategory('School & Education')),
        buildCategoryItem(
            title: 'Sports',
            icon: CategoryIconMapper.iconForCategory('Sports')),
        buildCategoryItem(
            title: 'Technology',
            icon: CategoryIconMapper.iconForCategory('Technology')),
        buildCategoryItem(
            title: 'Volunteering',
            icon: CategoryIconMapper.iconForCategory('Volunteering')),
      ],
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
