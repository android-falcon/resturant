import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomTextFieldNum extends StatelessWidget {

  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final TextEditingController? controller;
  final Color? textColor;
  final Color? fillColor;
  final TextInputType? keyboardType;
  final bool enableInteractiveSelection;
  final bool enabled;
  final void Function()? onTap;

  const CustomTextFieldNum({
    Key? key,
    this.margin,
    this.padding,
    this.controller,
    this.textColor,
    this.fillColor,
    this.keyboardType,
    this.enableInteractiveSelection = false,
    this.enabled = true,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      height: 30,
      child: TextFormField(
        enableInteractiveSelection: enableInteractiveSelection,
        style: Theme.of(context).textTheme.bodyText2!.copyWith(color: textColor),
        controller: controller,
        keyboardType: keyboardType,
        maxLines: 1,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          fillColor: fillColor ?? Colors.transparent,
          filled: true,
          contentPadding: const EdgeInsets.only(top: -14.0),
          hintStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: textColor),
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        enabled: enabled,
        onTap: onTap,
      ),
    );
  }
}
