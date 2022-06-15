import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/utils/color.dart';

typedef CustomDialogBuilder = Widget Function(BuildContext context, StateSetter setState, BoxConstraints constraints);

class CustomDialog extends StatelessWidget {
  final CustomDialogBuilder builder;
  final GestureTapCallback? gestureDetectorOnTap;
  const CustomDialog({Key? key, required this.builder, this.gestureDetectorOnTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(4.w),
      backgroundColor: ColorsApp.backgroundDialog,
      content: StatefulBuilder(
        builder: (context, setState) => GestureDetector(
          onTap: () {
            FocusScope.of(context).requestFocus(FocusNode());
            gestureDetectorOnTap;
            setState(() {});
          },
          child: SizedBox(
            width: 0.95.sw,
            height: 0.95.sh,
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                child: builder(context, setState, constraints),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
