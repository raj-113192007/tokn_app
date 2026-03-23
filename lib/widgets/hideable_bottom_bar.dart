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
        final bool isVisible = scrollNotifier.isBarVisible;
        
        return AnimatedOpacity(
          duration: animationDuration,
          curve: Curves.easeOut,
          opacity: isVisible ? 1.0 : 0.0,
          child: AnimatedSlide(
            duration: isVisible 
                ? const Duration(milliseconds: 800) // Longer for elastic settle
                : const Duration(milliseconds: 300),
            curve: isVisible ? Curves.elasticOut : Curves.easeInQuad,
            offset: isVisible ? Offset.zero : const Offset(0, 1.2),
            child: AnimatedScale(
              duration: isVisible 
                  ? const Duration(milliseconds: 600) 
                  : const Duration(milliseconds: 250),
              curve: isVisible ? Curves.easeOutBack : Curves.easeInQuad,
              scale: isVisible ? 1.0 : 0.85,
              child: SizedBox(
                height: height + margin.bottom,
                child: GlassBottomBar(
                  height: height,
                  blur: blur,
                  opacity: opacity,
                  borderRadius: borderRadius,
                  margin: margin,
                  backgroundColor: backgroundColor,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
