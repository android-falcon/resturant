import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_system/models/category_model.dart';
import 'package:restaurant_system/models/item_model.dart';
import 'package:restaurant_system/screens/widgets/custom_single_child_scroll_view.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/enum_order_type.dart';

class OrderScreen extends StatefulWidget {
  final OrderType type;

  const OrderScreen({Key? key, required this.type}) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  bool _isShowItem = false;
  int _selectedCategoryId = 0;
  List<CategoryModel> categories = [
    CategoryModel(id: 1, name: 'Test', image: 'assets/images/falcons.png', items: [ItemModel(name: 'Item TEst', description: 'description', image: 'assets/images/falcons.png', price: 5.3), ItemModel(name: 'Item sd', description: 'description', image: 'assets/images/falcons.png', price: 4)]),
    CategoryModel(id: 2, name: 'Test1', image: 'assets/images/falcons.png', items: [ItemModel(name: 'Item TEst2', description: 'description', image: 'assets/images/falcons.png', price: 5.3)]),
    CategoryModel(id: 3, name: 'Test3', image: 'assets/images/falcons.png', items: [ItemModel(name: 'Item TEst2', description: 'description', image: 'assets/images/falcons.png', price: 5.3)]),
    CategoryModel(id: 4, name: 'Test3', image: 'assets/images/falcons.png', items: [ItemModel(name: 'Item TEst2', description: 'description', image: 'assets/images/falcons.png', price: 5.3)]),
    CategoryModel(id: 5, name: 'Test3', image: 'assets/images/falcons.png', items: [ItemModel(name: 'Item TEst2', description: 'description', image: 'assets/images/falcons.png', price: 5.3)]),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_isShowItem) {
          _isShowItem = false;
          setState(() {});
          return false;
        }
        return true;
      },
      child: Scaffold(
        body: CustomSingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 50.h,
                color: Colors.white,
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        if (_isShowItem) {
                          _isShowItem = false;
                          setState(() {});
                        } else {
                          Get.back();
                        }
                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      widget.type == OrderType.takeAway ? 'Take Away'.tr : 'Dine In'.tr,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: kStyleTextDefault,
                    ),
                    SizedBox(width: 4.w),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: Text(
                        '${'Vh No'.tr} : ',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: kStyleTextDefault,
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: Text(
                        '${'Table'.tr} : ',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: kStyleTextDefault,
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: Text(
                        '${'Check'.tr} : ',
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: kStyleTextDefault,
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: Text(
                        DateFormat('yyyy/MM/dd').format(DateTime.now()),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: kStyleTextDefault,
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/lock.png',
                          height: 45.h,
                        ),
                        Text(
                          'Ali Ahmad',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: kStyleTextDefault,
                        ),
                      ],
                    ),
                    SizedBox(width: 4.w),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/lock.png',
                          height: 45.h,
                        ),
                        Text(
                          '2',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: kStyleTextDefault,
                        ),
                      ],
                    ),
                    SizedBox(width: 4.w),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Row(
                      children: [
                        Image.asset(
                          'assets/images/lock.png',
                          height: 45.h,
                        ),
                        Text(
                          '2',
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: kStyleTextDefault,
                        ),
                      ],
                    ),
                    SizedBox(width: 4.w),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: StaggeredGrid.count(
                          crossAxisCount: _isShowItem ? 2 : 3,
                          children: _isShowItem
                              ? categories
                                  .firstWhere((element) => element.id == _selectedCategoryId)
                                  .items
                                  .map(
                                    (e) => Card(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5.r),
                                      ),
                                      elevation: 0,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(5.r),
                                        onTap: () {},
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
                                          child: Row(
                                            children: [
                                              Image.asset(
                                                e.image,
                                                height: 50.h,
                                                width: 50.w,
                                                fit: BoxFit.contain,
                                              ),
                                              Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    e.name,
                                                    style: kStyleTextTitle,
                                                  ),
                                                  Text(
                                                    e.description,
                                                    style: kStyleTextDefault,
                                                  ),
                                                  Text(
                                                    e.price.toStringAsFixed(2),
                                                    style: kStyleTextTitle,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                  .toList()
                              : categories
                                  .map((e) => Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(5.r),
                                        ),
                                        elevation: 0,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(5.r),
                                          onTap: () {
                                            _selectedCategoryId = e.id;
                                            _isShowItem = true;
                                            setState(() {});
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 2.w),
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Image.asset(
                                                  e.image,
                                                  height: 50.h,
                                                  width: 50.w,
                                                  fit: BoxFit.contain,
                                                ),
                                                Text(
                                                  e.name,
                                                  style: kStyleTextTitle,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ))
                                  .toList(),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text('ana'),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 50.h,
                color: ColorsApp.accentColor,
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Text(
                          'Modifier'.tr,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: kStyleTextDefault,
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Text(
                          'Void'.tr,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: kStyleTextDefault,
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Text(
                          'Delivery'.tr,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: kStyleTextDefault,
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Text(
                          'Line Discount'.tr,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: kStyleTextDefault,
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Text(
                          'Discount'.tr,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: kStyleTextDefault,
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Text(
                          'Split'.tr,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: kStyleTextDefault,
                        ),
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 2,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {},
                        child: Text(
                          'Price Change'.tr,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: kStyleTextDefault,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
