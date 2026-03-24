import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;
import '../../app_colors.dart';

class PlatformIndicator extends StatelessWidget {
  final Color? color;
  final double radius;

  const PlatformIndicator({
    super.key,
    this.color,
    this.radius = 10,
  });

  @override
  Widget build(BuildContext context) {
    if (Platform.isIOS) {
      return CupertinoActivityIndicator(
        color: color,
        radius: radius,
      );
    }

    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(color ?? AppColors.primaryRed),
    );
  }
}
