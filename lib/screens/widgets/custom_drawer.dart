import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:restaurant_system/utils/app_config/home_menu.dart';
import 'package:restaurant_system/utils/constant.dart';
import 'package:restaurant_system/utils/enums/enum_company_type.dart';
import 'package:restaurant_system/utils/assets.dart';


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
                        image: AssetImage(Assets.kAssetsDrawerHeader),
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
