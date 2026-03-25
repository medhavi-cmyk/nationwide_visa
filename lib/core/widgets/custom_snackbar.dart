import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nwdapp/core/globals.dart';
import '../app_colors.dart';

class CustomSnackbar {
  static OverlayEntry? _currentOverlay;
  static Timer? _timer;

  static void show(String message, {bool isError = true}) {
    // 1. Remove existing snackbar if any
    dismiss();

    // 2. Get the navigation state and overlay
    final state = navigatorKey.currentState;
    final overlay = state?.overlay;
    if (overlay == null) {
      debugPrint("CustomSnackbar: Overlay not found via navigatorKey.");
      return;
    }


    // 3. Create the OverlayEntry
    _currentOverlay = OverlayEntry(
      builder: (context) {
        return _SnackbarWidget(
          message: message,
          isError: isError,
          onDismiss: dismiss,
        );
      },
    );

    // 4. Insert and set timer
    overlay.insert(_currentOverlay!);
    _timer = Timer(const Duration(seconds: 4), () {
      dismiss();
    });
  }

  static void dismiss() {
    _timer?.cancel();
    _timer = null;
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  static void showError(String message) {
    show(message, isError: true);
  }

  static void showSuccess(String message) {
    show(message, isError: false);
  }
}

class _SnackbarWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;

  const _SnackbarWidget({
    required this.message,
    required this.isError,
    required this.onDismiss,
  });

  @override
  State<_SnackbarWidget> createState() => _SnackbarWidgetState();
}

class _SnackbarWidgetState extends State<_SnackbarWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 20,
      left: 20,
      right: 20,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isError ? AppColors.primaryRed : AppColors.success,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  widget.isError ? Icons.error_outline : Icons.check_circle_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.message,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
