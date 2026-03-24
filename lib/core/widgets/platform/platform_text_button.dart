import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const PlatformTextButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      return CupertinoButton(
        onPressed: onPressed,
        padding: padding ?? EdgeInsets.zero,
        minSize: 0,
        child: child,
      );
    }
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: padding,
      ),
      child: child,
    );
  }
}
