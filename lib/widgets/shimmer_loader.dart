import 'package:flutter/material.dart';
import '../core/theme/dex_colors.dart';

/// Premium animated skeleton loader with dual-pass gradient shimmer
/// and subtle pulse opacity for a living, breathing loading state.
class ShimmerLoader extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool circle;

  const ShimmerLoader({
    super.key,
    this.width = double.infinity,
    this.height = 60,
    this.borderRadius = 16,
    this.circle = false,
  });

  @override
  State<ShimmerLoader> createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader>
    with TickerProviderStateMixin {
  late AnimationController _shimmerController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_shimmerController, _pulseController]),
      builder: (_, __) {
        final baseOpacity = 0.7 + _pulseController.value * 0.3;

        return Opacity(
          opacity: baseOpacity,
          child: Container(
            width: widget.width,
            height: widget.height,
            decoration: BoxDecoration(
              borderRadius: widget.circle
                  ? null
                  : BorderRadius.circular(widget.borderRadius),
              shape: widget.circle ? BoxShape.circle : BoxShape.rectangle,
              gradient: LinearGradient(
                begin: Alignment(-1.5 + 3.0 * _shimmerController.value, -0.3),
                end: Alignment(-0.5 + 3.0 * _shimmerController.value, 0.3),
                colors: [
                  DexColors.surface,
                  DexColors.surfaceLight.withValues(alpha: 0.8),
                  DexColors.primary.withValues(alpha: 0.06),
                  DexColors.surfaceLight.withValues(alpha: 0.8),
                  DexColors.surface,
                ],
                stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Row of shimmer text placeholders for loading text content
class ShimmerTextBlock extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;

  const ShimmerTextBlock({
    super.key,
    this.lines = 3,
    this.lineHeight = 12,
    this.spacing = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(lines, (i) {
        final widthFactor = i == lines - 1 ? 0.6 : (0.8 + (i % 2) * 0.2);
        return Padding(
          padding: EdgeInsets.only(bottom: i < lines - 1 ? spacing : 0),
          child: FractionallySizedBox(
            widthFactor: widthFactor,
            child: ShimmerLoader(height: lineHeight, borderRadius: 4),
          ),
        );
      }),
    );
  }
}
