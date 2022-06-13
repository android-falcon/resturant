import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:restaurant_system/screens/widgets/custom_button.dart';
import 'package:restaurant_system/utils/color.dart';

class NumPad extends StatelessWidget {
  final TextEditingController? controller;
  void Function()? onPressed1;
  void Function()? onPressed2;
  void Function()? onPressed3;
  void Function()? onPressed4;
  void Function()? onPressed5;
  void Function()? onPressed6;
  void Function()? onPressed7;
  void Function()? onPressed8;
  void Function()? onPressed9;
  void Function()? onPressedDot;
  void Function()? onPressed0;
  void Function()? onPressedDelete;
  void Function()? onSubmit;
  void Function()? onExit;
  final EdgeInsetsGeometry marginButton;
  final EdgeInsetsGeometry paddingButton;

  NumPad({
    Key? key,
    this.controller,
    this.onPressed1,
    this.onPressed2,
    this.onPressed3,
    this.onPressed4,
    this.onPressed5,
    this.onPressed6,
    this.onPressed7,
    this.onPressed8,
    this.onPressed9,
    this.onPressedDot,
    this.onPressed0,
    this.onPressedDelete,
    this.onSubmit,
    this.onExit,
    this.marginButton = const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
    this.paddingButton = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: CustomButton(
                margin: marginButton,
                padding: paddingButton,
                child: const Text('1'),
                onPressed: onPressed1,
              ),
            ),
            Expanded(
              child: CustomButton(
                margin: marginButton,
                padding: paddingButton,
                child: const Text('2'),
                onPressed: onPressed2,
              ),
            ),
            Expanded(
              child: CustomButton(
                margin: marginButton,
                padding: paddingButton,
                child: const Text('3'),
                onPressed: onPressed3,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                margin: marginButton,
                padding: paddingButton,
                child: const Text('4'),
                onPressed: onPressed4,
              ),
            ),
            Expanded(
              child: CustomButton(
                margin: marginButton,
                padding: paddingButton,
                child: const Text('5'),
                onPressed: onPressed5,
              ),
            ),
            Expanded(
              child: CustomButton(
                margin: marginButton,
                padding: paddingButton,
                child: const Text('6'),
                onPressed: onPressed6,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                margin: marginButton,
                padding: paddingButton,
                child: const Text('7'),
                onPressed: onPressed7,
              ),
            ),
            Expanded(
              child: CustomButton(
                margin: marginButton,
                padding: paddingButton,
                child: const Text('8'),
                onPressed: onPressed8,
              ),
            ),
            Expanded(
              child: CustomButton(
                margin: marginButton,
                padding: paddingButton,
                child: const Text('9'),
                onPressed: onPressed9,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                margin: marginButton,
                padding: paddingButton,
                child: const Text('.'),
                onPressed: onPressedDot,
              ),
            ),
            Expanded(
              child: CustomButton(
                margin: marginButton,
                padding: paddingButton,
                child: const Text('0'),
                onPressed: onPressed0,
              ),
            ),
            Expanded(
              child: CustomButton(
                margin: marginButton,
                padding: paddingButton,
                child: const Icon(Icons.backspace, size: 18,),
                onPressed: onPressedDelete,
              ),
            ),
          ],
        ),
        Row(
          children: [
            if(onExit != null)
            Expanded(
              child: CustomButton(
                margin: marginButton,
                padding: paddingButton,
                child: Text('Exit'.tr),
                backgroundColor: ColorsApp.red,
                onPressed: onExit,
              ),
            ),
            if(onSubmit != null)
            Expanded(
              child: CustomButton(
                margin: marginButton,
                padding: paddingButton,
                child: Text('Save'.tr),
                backgroundColor: ColorsApp.green,
                onPressed: onSubmit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
