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
    return Container(
      margin: margin,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              color: backgroundColor ?? Colors.white.withOpacity(opacity),
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: Colors.white.withOpacity(0.1),
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
