import 'package:flutter/cupertino.dart';
import 'package:dima_project/utils/categories_icon_mapper.dart';

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
      children: CategoryIconMapper.categories.map((category) {
        return CategoryIconMapper.buildCategoryItem(
          title: category,
          icon: CategoryIconMapper.iconForCategory(category),
          onTap: () {
            setState(() {
              if (selectedCategories.contains(category)) {
                selectedCategories.remove(category);
              } else {
                selectedCategories.add(category);
              }
            });
          },
          selectedCategories: selectedCategories,
        );
      }).toList(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
