// ignore_for_file: avoid_print, unused_local_variable, unused_element, use_build_context_synchronously, unused_field, file_names, constant_identifier_names, deprecated_member_use, unused_import
import 'dart:ui';
import 'package:flutter/material.dart';

class GlassBottomBar extends StatelessWidget {
  final Widget child;
  final double height;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsets margin;
  final Color? backgroundColor;

  const GlassBottomBar({
    super.key,
    required this.child,
    this.height = 75,
    this.blur = 15,
    this.opacity = 0.1,
    this.borderRadius = 30,
    this.margin = const EdgeInsets.fromLTRB(20, 0, 20, 10),
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final Color baseBackground = backgroundColor ?? Colors.white;
    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            decoration: BoxDecoration(
              // Always apply the provided `opacity` so the glass/blur effect
              // remains visible even when a `backgroundColor` is passed in.
              color: baseBackground.withValues(alpha: opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.18),
                width: 0.8,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
