import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/models/all_data/category_model.dart';
import 'package:restaurant_system/models/all_data/item_model.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/utils.dart';

class SortingItemsScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const SortingItemsScreen({Key? key, required this.categoryId, required this.categoryName}) : super(key: key);

  @override
  State<SortingItemsScreen> createState() => _SortingItemsScreenState();
}

class _SortingItemsScreenState extends State<SortingItemsScreen> {
  List<ItemModel> items = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    items = allDataModel.items.where((element) => element.category.id == widget.categoryId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: ReorderableListView.builder(
        onReorder: (oldIndex, newIndex) {
          if (newIndex > oldIndex) {
            newIndex -= 1;
          }
          final ItemModel item = items.removeAt(oldIndex);
          items.insert(newIndex, item);

          for(int i = items.length - 1; i >= 0; i--){
            allDataModel.items.remove(items[i]);
            allDataModel.items.insert(0, items[i]);
          }
          setState(() {});
          Utils.saveSorting();

        },
        itemCount: items.length,
        itemBuilder: (context, indexItem) =>  ListTile(
                key: ValueKey(items[indexItem].id),
                title: Text(items[indexItem].menuName),
              ),
      ),
    );
  }
}
