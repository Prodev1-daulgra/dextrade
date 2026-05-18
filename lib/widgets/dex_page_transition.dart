import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Cinematic page transition with fade + subtle upward slide.
/// Used by GoRouter for all route transitions in the app.
class DexPageTransition extends CustomTransitionPage<void> {
  DexPageTransition({required Widget child, LocalKey? key})
    : super(
        key: key ?? ValueKey(child.runtimeType),
        child: child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final curvedAnimation = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          );

          return FadeTransition(
            opacity: curvedAnimation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.02),
                end: Offset.zero,
              ).animate(curvedAnimation),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
        reverseTransitionDuration: const Duration(milliseconds: 250),
      );
}
