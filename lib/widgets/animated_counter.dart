import 'package:flutter/material.dart';
import '../../core/theme/dex_colors.dart';

class AnimatedCounter extends StatelessWidget {
  final double value;
  final String prefix;
  final String suffix;
  final TextStyle? style;
  final int decimals;
  final Duration duration;

  const AnimatedCounter({
    super.key,
    required this.value,
    this.prefix = '\$',
    this.suffix = '',
    this.style,
    this.decimals = 2,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animValue, _) {
        final whole = animValue.truncate();
        final frac = ((animValue - whole) * 100).truncate().toString().padLeft(2, '0');
        return RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: '$prefix${_formatNumber(whole)}',
                style: style ?? TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w900,
                  color: DexColors.textPrimary,
                  letterSpacing: -1.5,
                ),
              ),
              if (decimals > 0)
                TextSpan(
                  text: '.$frac$suffix',
                  style: (style ?? TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.5,
                  )).copyWith(
                    color: DexColors.textPrimary.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }
}
