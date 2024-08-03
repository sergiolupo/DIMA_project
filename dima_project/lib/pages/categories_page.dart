import 'package:dima_project/widgets/categoriesform_widget.dart';
import 'package:flutter/cupertino.dart';

class CategoriesPage extends StatelessWidget {
  final List<String>? selectedCategories;

  const CategoriesPage({super.key, this.selectedCategories});

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        leading: Navigator.canPop(context)
            ? CupertinoNavigationBarBackButton(
                color: CupertinoTheme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            : null,
        middle: Text('Categories Selection',
            style: TextStyle(
                color: CupertinoTheme.of(context).primaryColor, fontSize: 18)),
      ),
      child: CategorySelectionForm(
        selectedCategories: selectedCategories,
      ),
    );
  }
}
