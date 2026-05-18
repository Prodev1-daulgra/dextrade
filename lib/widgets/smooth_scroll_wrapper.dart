import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SmoothScrollWrapper extends StatefulWidget {
  final Widget child;
  final ScrollController controller;
  final double scrollSpeed;
  final int animationDurationMs;

  const SmoothScrollWrapper({
    super.key,
    required this.child,
    required this.controller,
    this.scrollSpeed = 1.6,
    this.animationDurationMs = 350,
  });

  @override
  State<SmoothScrollWrapper> createState() => _SmoothScrollWrapperState();
}

class _SmoothScrollWrapperState extends State<SmoothScrollWrapper> {
  double _targetOffset = 0.0;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    // Synchronize initial scroll position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.controller.hasClients) {
        _targetOffset = widget.controller.offset;
      }
    });
  }

  void _onPointerSignal(PointerSignalEvent event) {
    // Only intercept mouse wheel signals on Web or Desktop platforms
    if (event is PointerScrollEvent && (kIsWeb || _isDesktopPlatform())) {
      final double delta = event.scrollDelta.dy * widget.scrollSpeed;

      if (!widget.controller.hasClients) return;

      final double maxScroll = widget.controller.position.maxScrollExtent;

      // If we are starting a scroll, sync current position first
      if (!_isAnimating) {
        _targetOffset = widget.controller.offset;
      }

      _targetOffset += delta;
      _targetOffset = _targetOffset.clamp(0.0, maxScroll);

      _isAnimating = true;
      widget.controller
          .animateTo(
            _targetOffset,
            duration: Duration(milliseconds: widget.animationDurationMs),
            curve: Curves.easeOutCubic,
          )
          .then((_) {
            _isAnimating = false;
          });
    }
  }

  bool _isDesktopPlatform() {
    return defaultTargetPlatform == TargetPlatform.macOS ||
        defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux;
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with Listener only on Web/Desktop viewports to preserve native touch dragging on mobile
    if (kIsWeb || _isDesktopPlatform()) {
      return Listener(onPointerSignal: _onPointerSignal, child: widget.child);
    }
    return widget.child;
  }
}
