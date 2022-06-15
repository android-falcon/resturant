import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:restaurant_system/utils/constant.dart';

class CustomTextField extends StatefulWidget {
  TextEditingController? controller;
  Color? fillColor;
  TextInputType? keyboardType;
  int? maxLines;
  int? maxLength;
  TextAlign textAlign;
  String? hintText;
  Widget? label;
  String? helperText;
  Widget? prefixIcon;
  Widget? suffixIcon;
  bool enableInteractiveSelection;
  bool enabled;
  bool obscureText;
  bool isPass;
  TextDirection? textDirection;
  String? Function(String? value)? validator;
  String? Function(String? value)? onChanged;
  String? Function(String? value)? onSaved;
  String? Function(String? value)? onFieldSubmitted;
  void Function()? onTap;
  EdgeInsetsGeometry? margin;
  EdgeInsetsGeometry? padding;
  EdgeInsetsGeometry? contentPadding;
  Color? textColor;
  List<TextInputFormatter>? inputFormatters;

  CustomTextField({
    this.controller,
    this.textColor,
    this.fillColor,
    this.keyboardType,
    this.maxLines,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.label,
    this.helperText,
    this.contentPadding,
    this.enableInteractiveSelection = true,
    this.enabled = true,
    this.obscureText = false,
    this.isPass = false,
    this.textDirection,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onFieldSubmitted,
    this.onTap,
    this.margin = const EdgeInsets.symmetric(vertical: 4),
    this.padding,
    this.inputFormatters,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _visiblePassword = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
      padding: widget.padding,
      child: TextFormField(
        enableInteractiveSelection: widget.enableInteractiveSelection,
        style: kStyleTextDefault.copyWith(color: widget.textColor),
        controller: widget.controller,
        keyboardType: widget.keyboardType,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        maxLength: widget.maxLength,
        textAlign: widget.textAlign,
        // style: TextStyle(color: Colors.black),
        decoration: InputDecoration(
          fillColor: widget.fillColor ?? Colors.transparent,
          filled: true,
          hintText: widget.hintText,
          label: widget.label,

          helperText: widget.helperText,
          contentPadding: widget.contentPadding ?? (widget.prefixIcon != null ? EdgeInsets.zero : const EdgeInsetsDirectional.only(start: 20)),
          hintStyle: Theme.of(context).textTheme.bodyText2!.copyWith(color: widget.textColor),
          prefixIcon: widget.prefixIcon != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: widget.prefixIcon,
                )
              : null,
          suffixIcon: widget.isPass
              ? InkWell(
                  child: Icon(
                    _visiblePassword ? Icons.visibility : Icons.visibility_off,
                    color: Colors.black,
                    size: 14,
                  ),
                  onTap: () {
                    setState(() {
                      _visiblePassword = !_visiblePassword;
                      widget.obscureText = !widget.obscureText;
                    });
                  },
                )
              : widget.suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: widget.suffixIcon,
                    )
                  : null,
          counterStyle: const TextStyle(fontSize: 0, color: Colors.transparent),
          // suffixIcon: Padding(
          //   padding: EdgeInsets.only(right: 20),
          //   child: icon,
          // ),
          errorMaxLines: 3,
          // focusedBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(8),
          //   borderSide: const BorderSide(color: Colors.grey, width: 2),
          // ),
          // enabledBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(8),
          //   borderSide: const BorderSide(color: Colors.grey, width: 2),
          // ),
          // errorBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(8),
          //   borderSide: const BorderSide(color: Colors.red, width: 2),
          // ),
          // focusedErrorBorder: OutlineInputBorder(
          //   borderRadius: BorderRadius.circular(8),
          //   borderSide: const BorderSide(color: Colors.red, width: 2),
          // ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        enabled: widget.enabled,
        inputFormatters: widget.inputFormatters,
        obscureText: widget.obscureText,
        textDirection: widget.textDirection,
        validator: widget.validator,
        onChanged: widget.onChanged,
        onSaved: widget.onSaved,
        onFieldSubmitted: widget.onFieldSubmitted,
        onTap: widget.onTap,
      ),
    );
  }
}
