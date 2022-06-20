import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/screens/widgets/loading_dialog.dart';
import 'package:restaurant_system/screens/widgets/num_pad.dart';

bool isNotEmpty(String? s) => s != null && s.isNotEmpty;

bool isEmpty(String? s) => s == null || s.isEmpty;

showLoadingDialog([String? text]) {
  log('showLoadingIndicator Called !!');
  Get.dialog(
    WillPopScope(
      onWillPop: () async => false,
      child: LoadingDialog(
        title: text ?? 'Loading ...'.tr,
      ),
    ),
    barrierDismissible: false,
    useSafeArea: false,
  );
}

void hideLoadingDialog() {
  if (Get.isDialogOpen!) {
    Get.back();
  }
}

Widget numPadWidget(
  TextEditingController? controller,
  void Function(Function()) setState, {
  bool decimal = true,
  Function()? onSubmit,
}) {
  void addNumber(TextEditingController? controller, int number) {
    if (controller != null) {
      if (controller.text.contains('.')) {
        var split = controller.text.split('.');
        if (split[1].length < 2) {
          controller.text += '$number';
        }
      } else {
        controller.text += '$number';
        controller.text = '${int.parse(controller.text)}';
      }
    }
  }

  return NumPad(
    controller: controller,
    onSubmit: onSubmit,
    onExit: () {
      Get.back();
    },
    onPressed1: () {
      addNumber(controller, 1);
      setState(() {});
    },
    onPressed2: () {
      addNumber(controller, 2);
      setState(() {});
    },
    onPressed3: () {
      addNumber(controller, 3);
      setState(() {});
    },
    onPressed4: () {
      addNumber(controller, 4);
      setState(() {});
    },
    onPressed5: () {
      addNumber(controller, 5);
      setState(() {});
    },
    onPressed6: () {
      addNumber(controller, 6);
      setState(() {});
    },
    onPressed7: () {
      addNumber(controller, 7);
      setState(() {});
    },
    onPressed8: () {
      addNumber(controller, 8);
      setState(() {});
    },
    onPressed9: () {
      addNumber(controller, 9);
      setState(() {});
    },
    onPressedDot: () {
      if (decimal) {
        if (controller != null) {
          if (!controller.text.contains('.')) {
            controller.text += '.';
          }
        }
        setState(() {});
      }
    },
    onPressed0: () {
      addNumber(controller, 0);
      setState(() {});
    },
    onPressedDelete: () {
      if (controller != null) {
        if (controller.text.length > 1) {
          var split = controller.text.split('');
          split.removeLast();
          controller.text = split.join();
        } else {
          controller.text = '0';
        }
      }
      setState(() {});
    },
  );
}
