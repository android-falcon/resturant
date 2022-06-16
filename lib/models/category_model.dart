import 'package:restaurant_system/models/item_model.dart';

class CategoryModel {
  int id;
  String name;
  String image;
  List<ItemModel> items;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    required this.items,
  });
}
