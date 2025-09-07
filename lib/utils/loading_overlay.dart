import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LoadingOverlay extends StatelessWidget {
  final String message;
  const LoadingOverlay({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Blocks touches
        const ModalBarrier(dismissible: false, color: Colors.transparent),

        // Light blur + subtle dim
        Positioned.fill(
          child: IgnorePointer(
            ignoring: false,
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
              child: Container(color: Colors.black.withOpacity(0.06)),
            ),
          ),
        ),

        // Centered compact card with platform spinner
        Positioned.fill(
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const _PlatformSpinner(size: 22),
                    const SizedBox(width: 12),
                    Text(
                      message,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PlatformSpinner extends StatelessWidget {
  final double size;
  const _PlatformSpinner({this.size = 28});

  bool get _isIOS =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  @override
  Widget build(BuildContext context) {
    if (_isIOS) {
      // Cupertino-native spinner
      return const CupertinoActivityIndicator(radius: 12);
    }
    // Material spinner (brand-colored)
    return SizedBox(
      width: size,
      height: size,
      child: const CircularProgressIndicator(strokeWidth: 3),
    );
  }
}
