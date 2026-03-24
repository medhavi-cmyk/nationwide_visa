import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import '../../app_colors.dart';

class PlatformButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;

  const PlatformButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.backgroundColor,
    this.foregroundColor,
    this.borderRadius,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoButton(
        padding: padding ?? EdgeInsets.zero,
        onPressed: onPressed,
        color: backgroundColor ?? AppColors.primaryRed,
        borderRadius: BorderRadius.circular(borderRadius ?? 30),
        child: DefaultTextStyle.merge(
          style: TextStyle(
            color: foregroundColor ?? Colors.white,
            fontWeight: FontWeight.w800,
          ),
          child: child,
        ),
      );
    }

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? AppColors.primaryRed,
        foregroundColor: foregroundColor ?? Colors.white,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? 30),
        ),
        elevation: 0,
      ),
      child: child,
    );
  }
}
