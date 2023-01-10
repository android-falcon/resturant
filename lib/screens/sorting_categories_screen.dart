import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/models/all_data/category_model.dart';
import 'package:restaurant_system/screens/sorting_items_screen.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/utils.dart';

class SortingCategoriesScreen extends StatefulWidget {
  const SortingCategoriesScreen({Key? key}) : super(key: key);

  @override
  State<SortingCategoriesScreen> createState() => _SortingCategoriesScreenState();
}

class _SortingCategoriesScreenState extends State<SortingCategoriesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Categories'.tr),
      ),
      body: ReorderableListView.builder(
        onReorder: (oldIndex, newIndex) {
          // if (newIndex >= allDataModel.categories.length) return;
          // var tmp = allDataModel.categories[oldIndex];
          // allDataModel.categories[oldIndex] = allDataModel.categories[newIndex];
          // allDataModel.categories[newIndex] = tmp;
          // setState(() {});
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final CategoryModel item = allDataModel.categories.removeAt(oldIndex);
          allDataModel.categories.insert(newIndex, item);
          setState(() {});
          Utils.saveSorting();
        },
        itemCount: allDataModel.categories.length,
        itemBuilder: (context, indexCategory) => ListTile(
          key: ValueKey(allDataModel.categories[indexCategory].id),
          onTap: () {
            Get.to(() => SortingItemsScreen(categoryId: allDataModel.categories[indexCategory].id, categoryName: allDataModel.categories[indexCategory].categoryName));
          },
          title: Text(allDataModel.categories[indexCategory].categoryName),
        ),
      ),
    );
  }
}
