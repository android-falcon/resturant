import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  Widget? child;
  Color? backgroundColor;
  EdgeInsetsGeometry? padding;
  void Function()? onPressed;
  void Function()? onLongPress;
  EdgeInsetsGeometry? margin;
  double? width;
  double? height;
  bool? fixed;
  BorderSide? side;
  double? borderRadius;

  CustomButton({
    Key? key,
    this.child,
    this.backgroundColor,
    this.padding,
    this.borderRadius,
    this.width,
    this.height,
    this.fixed = false,
    this.onPressed,
    this.side,
    this.onLongPress,
    this.margin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin ?? const EdgeInsets.symmetric(vertical: 8),
      width: fixed! ? width : double.infinity,
      height: height,
      child: ElevatedButton(
        child:  child,
        style: ElevatedButton.styleFrom(
          onPrimary: Colors.black,
          primary: backgroundColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? 4),
            side: side ?? BorderSide.none,
          ),
          elevation: 0.0,
          shadowColor: Colors.transparent,
        ),

        onPressed: onPressed,
        onLongPress: onLongPress,
      ),
    );
  }
}
