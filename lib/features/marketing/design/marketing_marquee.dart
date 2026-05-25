import 'package:flutter/material.dart';

/// GPU-friendly horizontal marquee (no per-frame scroll controller jumps).
class MarketingMarquee extends StatefulWidget {
  final List<String> items;
  final double height;
  final TextStyle? style;
  final double speed;

  const MarketingMarquee({
    super.key,
    required this.items,
    this.height = 48,
    this.style,
    this.speed = 42,
  });

  @override
  State<MarketingMarquee> createState() => _MarketingMarqueeState();
}

class _MarketingMarqueeState extends State<MarketingMarquee>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = widget.style ??
        Theme.of(context).textTheme.labelMedium?.copyWith(letterSpacing: 2);

    return SizedBox(
      height: widget.height,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final label = widget.items.join('   ◆   ');
          final row = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: textStyle),
              const SizedBox(width: 48),
              Text(label, style: textStyle),
            ],
          );

          return AnimatedBuilder(
            animation: _controller,
            builder: (_, child) {
              final w = constraints.maxWidth > 0 ? constraints.maxWidth : 400;
              final dx = -(_controller.value * widget.speed) % (w * 0.5);
              return Transform.translate(offset: Offset(dx, 0), child: child);
            },
            child: row,
          );
        },
      ),
    );
  }
}
