import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
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
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
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
