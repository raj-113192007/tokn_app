import 'package:flutter/material.dart';
import 'glass_bottom_bar.dart';
import '../services/scroll_notifier.dart';

class HideableBottomBar extends StatelessWidget {
  final Widget child;
  final ScrollNotifier scrollNotifier;
  final double height;
  final double blur;
  final double opacity;
  final double borderRadius;
  final EdgeInsets margin;
  final Color? backgroundColor;
  final Duration animationDuration;

  const HideableBottomBar({
    super.key,
    required this.child,
    required this.scrollNotifier,
    this.height = 75,
    this.blur = 15,
    this.opacity = 0.1,
    this.borderRadius = 30,
    this.margin = const EdgeInsets.fromLTRB(20, 0, 20, 10),
    this.backgroundColor,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: scrollNotifier,
      builder: (context, _) {
        return AnimatedContainer(
          duration: animationDuration,
          curve: Curves.easeInOut,
          height: scrollNotifier.isBarVisible ? height : 0,
          child: GlassBottomBar(
            height: height,
            blur: blur,
            opacity: opacity,
            borderRadius: borderRadius,
            margin: margin,
            backgroundColor: backgroundColor,
            child: child,
          ),
        );
      },
    );
  }
}
