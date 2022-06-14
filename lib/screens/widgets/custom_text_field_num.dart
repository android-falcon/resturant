import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_system/utils/text_input_formatters.dart';

class CustomTextFieldNum extends StatelessWidget {

  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final TextEditingController? controller;
  final Color? textColor;
  final Color? fillColor;
  final TextInputType? keyboardType;
  final bool enableInteractiveSelection;
  final bool enabled;
  final bool decimal;
  final void Function()? onTap;
  final String? Function(String?)? validator;

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
    this.decimal = true,
    this.onTap,
    this.validator,
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
        keyboardType: keyboardType ?? const TextInputType.numberWithOptions(),
        maxLines: 1,
        textAlign: TextAlign.center,
        inputFormatters: [
          EnglishDigitsTextInputFormatter(decimal: decimal),
        ],
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
        validator: validator,
      ),
    );
  }
}
