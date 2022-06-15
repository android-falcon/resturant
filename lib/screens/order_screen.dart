import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      Get.back();
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
                children: [
                  Text('ana')
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
    );
  }
}
