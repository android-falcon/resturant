import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_system/utils/app_config/home_menu.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:restaurant_system/models/cart_model.dart';
import 'package:restaurant_system/models/end_cash_model.dart';
import 'package:restaurant_system/models/printer_image_model.dart';
import 'package:restaurant_system/networks/rest_api.dart';
import 'package:restaurant_system/printer/printer.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/screens/widgets/custom_dialog.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field.dart';
import 'package:restaurant_system/screens/widgets/custom_text_field_num.dart';
import 'package:restaurant_system/utils/app_config/money_count.dart';
import 'package:restaurant_system/utils/color.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/enums/enum_company_type.dart';
import 'package:restaurant_system/utils/enums/enum_in_out_type.dart';
import 'package:restaurant_system/utils/enums/enum_invoice_kind.dart';
import 'package:restaurant_system/utils/enums/enum_order_type.dart';
import 'package:restaurant_system/utils/global_variable.dart';
import 'package:restaurant_system/utils/my_shared_preferences.dart';
import 'package:restaurant_system/utils/text_input_formatters.dart';
import 'package:restaurant_system/utils/validation.dart';
import 'package:screenshot/screenshot.dart';

class CustomDrawer extends StatefulWidget {
  final List<HomeMenu> menu;

  const CustomDrawer({Key? key, required this.menu}) : super(key: key);

  @override
  CustomDrawerState createState() => CustomDrawerState();
}

class CustomDrawerState extends State<CustomDrawer> {
  @override
  Widget build(BuildContext context) {
    return ClipPath(
      // clipper: OvalRightBorderClipper(),
      child: SizedBox(
        width: 120.w,
        child: Drawer(
          child: Column(
            children: [
              SizedBox(
                height: 100.h,
                width: 120.w,
                child: DrawerHeader(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(1.0),
                      image: DecorationImage(
                        image: AssetImage(kAssetsDrawerHeader),
                        fit: BoxFit.contain,
                      ),
                    ),
                    child: Visibility(
                      visible: companyType == CompanyType.falcons,
                      child: const Text("FalconsSoft"),
                    ),
                  ),
                  margin: const EdgeInsets.only(bottom: 2),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: widget.menu.length,
                  shrinkWrap: true,
                  itemBuilder: (context, index) => InkWell(
                    onTap: widget.menu[index].onTab,
                    child: ListTile(
                      trailing: widget.menu[index].icon,
                      title: Text(
                        widget.menu[index].name,
                        style: kStyleTextDefault,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
