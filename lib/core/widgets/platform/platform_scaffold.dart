import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class PlatformScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Widget? bottomNavigationBar;

  const PlatformScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.backgroundColor,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;
    if (isIOS) {
      return CupertinoPageScaffold(
        backgroundColor: backgroundColor ?? CupertinoColors.systemBackground,
        navigationBar: title != null || titleWidget != null || leading != null || actions != null
            ? CupertinoNavigationBar(
                middle: titleWidget ?? (title != null ? Text(title!) : null),
                leading: leading,
                trailing: actions != null && actions!.isNotEmpty
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: actions!,
                      )
                    : null,
              )
            : null,
        child: SafeArea(child: body),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: title != null || titleWidget != null || leading != null || actions != null
          ? AppBar(
              title: titleWidget ?? (title != null ? Text(title!) : null),
              leading: leading,
              actions: actions,
            )
          : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
