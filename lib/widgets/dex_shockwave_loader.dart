import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/dex_colors.dart';

/// Copyhood-inspired shockwave loader — brand pulse, not a generic spinner.
class DexShockwaveLoader extends StatefulWidget {
  final double size;
  final String? brandLabel;
  final Color accent;

  const DexShockwaveLoader({
    super.key,
    this.size = 120,
    this.brandLabel,
    this.accent = DexColors.primary,
  });

  @override
  State<DexShockwaveLoader> createState() => _DexShockwaveLoaderState();
}

class _DexShockwaveLoaderState extends State<DexShockwaveLoader>
    with TickerProviderStateMixin {
  late final AnimationController _wave;
  late final AnimationController _float;
  late final AnimationController _glow;

  @override
  void initState() {
    super.initState();
    _wave = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _float = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _glow = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _wave.dispose();
    _float.dispose();
    _glow.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size + (widget.brandLabel != null ? 36 : 0),
      child: AnimatedBuilder(
        animation: Listenable.merge([_wave, _float, _glow]),
        builder: (_, __) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: widget.size,
                  height: widget.size,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      _ShockRing(t: _wave.value, delay: 0, color: widget.accent),
                      _ShockRing(
                        t: (_wave.value + 0.33) % 1.0,
                        delay: 0.5,
                        color: widget.accent,
                      ),
                      _ShockRing(
                        t: (_wave.value + 0.66) % 1.0,
                        delay: 1.0,
                        color: widget.accent,
                      ),
                      Container(
                        width: widget.size * 0.22,
                        height: widget.size * 0.22,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: widget.accent.withValues(
                                alpha: 0.35 + _glow.value * 0.25,
                              ),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      Transform.translate(
                        offset: Offset(0, 6 * (1 - _float.value * 2)),
                        child: Transform.scale(
                          scale: 0.92 + _float.value * 0.08,
                          child: Container(
                            width: widget.size * 0.38,
                            height: widget.size * 0.38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  widget.accent,
                                  widget.accent.withValues(alpha: 0.7),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.accent.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.bolt_rounded,
                              color: Colors.black,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (widget.brandLabel != null) ...[
                  const SizedBox(height: 20),
                  Text(
                    widget.brandLabel!.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 4,
                      color: Colors.white.withValues(alpha: 0.35),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      );
    );
  }
}

class _ShockRing extends StatelessWidget {
  final double t;
  final double delay;
  final Color color;

  const _ShockRing({
    required this.t,
    required this.delay,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final p = ((t - delay) % 1.0).clamp(0.0, 1.0);
    final scale = 0.75 + p * 4.5;
    final opacity = (1 - p) * 0.55;

    return Transform.scale(
      scale: scale,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withValues(alpha: opacity),
            width: p > 0.05 ? 2 : 3,
          ),
        ),
      ),
    );
  }
}
