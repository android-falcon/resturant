import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_system/models/category_model.dart';
import 'package:restaurant_system/models/item_model.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
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
  List<CategoryModel> categories = categoryModelFromJson('[{"Id": 1, "CategoryName": "ice cream", "CategoryPic": "image003.png"}, {"Id": 2, "CategoryName": "hot drinks", "CategoryPic": "uuu.png"}]');
  List<ItemModel> items = itemModelFromJson('[{"Id":2,"ITEM_BARCODE":"112233","Category":{"Id":1,"CategoryName":"ice cream","CategoryPic":"image003.png"},"CategoryId":1,"MENU_NAME":"test item name","Family":{"Id":1,"FamilyName":"test family","FamilyPic":"iconfinder_box-in_299102.png"},"FamilyId":1,"PRICE":5.5,"TaxType":{"Id":1,"TaxTypeName":"free tax"},"TaxTypeId":1,"TaxPerc":{"Id":5,"Percent":16,"AddDate":"2022-05-15T00:00:00"},"TaxPercId":5,"SECONDARY_NAME":"secode name","KITCHEN_ALIAS":"Kitchen name test","Item_STATUS":0,"ITEM_TYPE":null,"DESCRIPTION":"item description test","Unit":null,"UnitId":0,"WASTAGE_PERCENT":null,"DISCOUNT_AVAILABLE":0,"POINT_AVAILABLE":"0","OPEN_PRICE":0,"KitchenPrinter":{"Id":2,"PrinterName":"Printer2"},"KitchenPrinterId":2,"USED":null,"SHOW_IN_MENU":1,"ITEM_PICTURE":null}]');

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
                color: ColorsApp.gray,
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
                          'assets/images/waiter.png',
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
                          'assets/images/kitchen.png',
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
                          'assets/images/guests.png',
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
                              ? items
                                  .where((element) => element.categoryId == _selectedCategoryId)
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
                                              Image.network(
                                                e.itemPicture,
                                                height: 50.h,
                                                width: 50.w,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, object, stackTrace) => SizedBox(
                                                  height: 50.h,
                                                  width: 50.w,
                                                ),
                                              ),
                                              Expanded(
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      e.menuName,
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
                                                Image.network(
                                                  e.categoryPic,
                                                  height: 50.h,
                                                  width: 50.w,
                                                  fit: BoxFit.contain,
                                                  errorBuilder: (context, object, stackTrace) => SizedBox(
                                                    height: 50.h,
                                                    width: 50.w,
                                                  ),
                                                ),
                                                Text(
                                                  e.categoryName,
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
                    SingleChildScrollView(
                      child: Container(
                        width: 110.w,
                        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            child: Text(
                                          'Qty'.tr,
                                          style: kStyleHeaderTable,
                                          textAlign: TextAlign.center,
                                        )),
                                        Expanded(
                                            child: Text(
                                          'Pro-Nam'.tr,
                                          style: kStyleHeaderTable,
                                          textAlign: TextAlign.center,
                                        )),
                                        Expanded(
                                            child: Text(
                                          'Price'.tr,
                                          style: kStyleHeaderTable,
                                          textAlign: TextAlign.center,
                                        )),
                                        Expanded(
                                            child: Text(
                                          'Total'.tr,
                                          style: kStyleHeaderTable,
                                          textAlign: TextAlign.center,
                                        )),
                                      ],
                                    ),
                                  ),
                                  const Divider(color: Colors.black, height: 1),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                                    child: ListView.builder(
                                      itemCount: 0,
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, index) => Text('ana'),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // CustomDataTable(
                            //   minWidth: 106.w,
                            //   rows: [],
                            //   columns: [
                            //     DataColumn(label: Text('Qty'.tr)),
                            //     DataColumn(label: Text('Pro-Nam'.tr)),
                            //     DataColumn(label: Text('Price'.tr)),
                            //     DataColumn(label: Text('Total'.tr)),
                            //   ],
                            // ),
                            Container(
                              margin: EdgeInsets.symmetric(vertical: 4.h),
                              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.h),
                              decoration: BoxDecoration(
                                border: Border.all(),
                                borderRadius: BorderRadius.circular(3.r),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Total'.tr,
                                          style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        '0.00',
                                        style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Delivery Charge'.tr,
                                          style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        '0.00',
                                        style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Line Discount'.tr,
                                          style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        '0.00',
                                        style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Discount'.tr,
                                          style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        '0.00',
                                        style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  const Divider(color: Colors.black),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Sub Total'.tr,
                                          style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        '0.00',
                                        style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Service'.tr,
                                          style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        '0.00',
                                        style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Tax'.tr,
                                          style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        '0.00',
                                        style: kStyleTextDefault.copyWith(color: ColorsApp.green, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Amount Due'.tr,
                                          style: kStyleTextDefault.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      Text(
                                        '0.00',
                                        style: kStyleTextDefault.copyWith(color: ColorsApp.red, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    child: Text(
                                      'Pay'.tr,
                                      style: kStyleTextButton,
                                    ),
                                    fixed: true,
                                    backgroundColor: ColorsApp.green,
                                    onPressed: () {},
                                  ),
                                ),
                                SizedBox(width: 5.w),
                                Expanded(
                                  child: CustomButton(
                                    child: Text(
                                      'Order'.tr,
                                      style: kStyleTextButton,
                                    ),
                                    fixed: true,
                                    backgroundColor: ColorsApp.red,
                                    onPressed: () {},
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
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
