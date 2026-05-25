import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/dex_colors.dart';
import '../core/theme/dex_typography.dart';
import 'dart:async';

enum ToastType { success, error, info }

class DexToast {
  static void show(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        message: message,
        type: type,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }

  /// Ultra-premium iOS-style push notification banner.
  /// Features: frosted glass, swipe-to-dismiss, haptic feedback, auto-dismiss with progress,
  /// app icon, timestamp, and cinematic entrance animation.
  static void showPushNotification(
    BuildContext context, {
    required String title,
    required String body,
    IconData? icon,
    Color? accentColor,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 5),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    HapticFeedback.mediumImpact();

    entry = OverlayEntry(
      builder: (context) => _PremiumPushNotification(
        title: title,
        body: body,
        icon: icon,
        accentColor: accentColor,
        autoDismissDuration: duration,
        onDismiss: () {
          if (entry.mounted) entry.remove();
        },
        onTap: () {
          if (entry.mounted) entry.remove();
          onTap?.call();
        },
      ),
    );

    overlay.insert(entry);
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Simple inline toast (kept for backward compat)
// ═══════════════════════════════════════════════════════════════════

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const _ToastWidget({
    required this.message,
    required this.type,
    required this.onDismiss,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget> {
  bool _dismissing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 4), _startDismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startDismiss() {
    if (mounted && !_dismissing) {
      setState(() => _dismissing = true);
      Future.delayed(const Duration(milliseconds: 300), widget.onDismiss);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color accentColor;
    IconData icon;

    switch (widget.type) {
      case ToastType.success:
        accentColor = DexColors.success;
        icon = Icons.check_circle_rounded;
        break;
      case ToastType.error:
        accentColor = DexColors.error;
        icon = Icons.error_rounded;
        break;
      case ToastType.info:
        accentColor = DexColors.primary;
        icon = Icons.info_rounded;
        break;
    }

    final child = SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 24, right: 24),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _startDismiss,
              onPanUpdate: (details) {
                if (details.delta.dy < -5) _startDismiss();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: DexColors.surfaceLight.withValues(alpha: 0.95),
                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: accentColor.withValues(alpha: 0.1),
                      blurRadius: 20,
                      spreadRadius: -5,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: accentColor, size: 24)
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(
                          duration: 2000.ms,
                          color: accentColor.withValues(alpha: 0.5),
                        ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: DexTypography.bodyMedium.copyWith(
                          color: DexColors.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (_dismissing) {
      return child
          .animate()
          .slideY(begin: 0, end: -1, duration: 300.ms, curve: Curves.easeIn)
          .fadeOut(duration: 300.ms);
    } else {
      return child
          .animate()
          .slideY(
            begin: -1,
            end: 0,
            duration: 400.ms,
            curve: Curves.easeOutBack,
          )
          .fadeIn(duration: 400.ms);
    }
  }
}

// ═══════════════════════════════════════════════════════════════════
//  ULTRA-PREMIUM iOS-STYLE PUSH NOTIFICATION
//  - Frosted glass backdrop
//  - Swipe-to-dismiss with spring physics
//  - Auto-dismiss progress indicator
//  - Haptic feedback on interactions
//  - App icon with gradient
//  - Cinematic entrance/exit animations
// ═══════════════════════════════════════════════════════════════════

class _PremiumPushNotification extends StatefulWidget {
  final String title;
  final String body;
  final IconData? icon;
  final Color? accentColor;
  final Duration autoDismissDuration;
  final VoidCallback onDismiss;
  final VoidCallback? onTap;

  const _PremiumPushNotification({
    required this.title,
    required this.body,
    this.icon,
    this.accentColor,
    required this.autoDismissDuration,
    required this.onDismiss,
    this.onTap,
  });

  @override
  State<_PremiumPushNotification> createState() =>
      _PremiumPushNotificationState();
}

class _PremiumPushNotificationState extends State<_PremiumPushNotification>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _progressController;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  double _dragOffset = 0;
  bool _isDismissing = false;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();

    // Entrance animation
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _slideAnim = Tween<Offset>(begin: const Offset(0, -1.5), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entranceController,
            curve: Curves.easeOutCubic,
          ),
        );

    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: const Interval(0.0, 0.6),
      ),
    );

    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _entranceController, curve: Curves.easeOutBack),
    );

    _entranceController.forward();

    // Auto-dismiss progress
    _progressController = AnimationController(
      vsync: this,
      duration: widget.autoDismissDuration,
    );
    _progressController.forward();
    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_isDismissing) {
        _dismiss();
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_isDismissing) return;
    _isDismissing = true;
    HapticFeedback.lightImpact();
    _entranceController.reverse().then((_) {
      widget.onDismiss();
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    if (_isDismissing) return;
    setState(() {
      _dragOffset += details.delta.dy;
      if (_dragOffset > 0) _dragOffset = 0; // Prevent dragging downward
    });
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_isDismissing) return;
    if (_dragOffset < -60 || details.velocity.pixelsPerSecond.dy < -200) {
      _dismiss();
    } else {
      setState(() => _dragOffset = 0);
    }
  }

  Color _resolveAccent() {
    if (widget.accentColor != null) return widget.accentColor!;
    final t = widget.title.toLowerCase();
    if (t.contains('error') || t.contains('fail')) return DexColors.error;
    if (t.contains('success') ||
        t.contains('executed') ||
        t.contains('approved'))
      return DexColors.success;
    if (t.contains('warning')) return DexColors.warning;
    return DexColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final accent = _resolveAccent();

    return AnimatedBuilder(
      animation: _entranceController,
      builder: (context, child) {
        return Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: FadeTransition(
            opacity: _fadeAnim,
            child: SlideTransition(
              position: _slideAnim,
              child: ScaleTransition(scale: _scaleAnim, child: child),
            ),
          ),
        );
      },
      child: SafeArea(
        child: Transform.translate(
          offset: Offset(0, _dragOffset),
          child: GestureDetector(
            onVerticalDragUpdate: _onVerticalDragUpdate,
            onVerticalDragEnd: _onVerticalDragEnd,
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              HapticFeedback.selectionClick();
              widget.onTap?.call();
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: Padding(
              padding: const EdgeInsets.only(top: 8, left: 12, right: 12),
              child: AnimatedScale(
                scale: _isPressed ? 0.97 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeInOut,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        color: const Color(0xFF16162A).withValues(alpha: 0.88),
                        border: Border.all(
                          color: accent.withValues(alpha: 0.15),
                          width: 0.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.5),
                            blurRadius: 40,
                            spreadRadius: -8,
                            offset: const Offset(0, 16),
                          ),
                          BoxShadow(
                            color: accent.withValues(alpha: 0.08),
                            blurRadius: 30,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // App Icon — Premium gradient with glow ring
                                Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(11),
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        accent,
                                        accent.withValues(alpha: 0.6),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: accent.withValues(alpha: 0.3),
                                        blurRadius: 12,
                                        spreadRadius: -2,
                                      ),
                                    ],
                                  ),
                                  child: Center(
                                    child: widget.icon != null
                                        ? Icon(
                                            widget.icon,
                                            color: Colors.white,
                                            size: 20,
                                          )
                                        : Text(
                                            'D',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 18,
                                              fontWeight: FontWeight.w900,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Content
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      // Top row: app name + timestamp
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'DEXTRADE',
                                            style: GoogleFonts.spaceGrotesk(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: DexColors.textMuted,
                                              letterSpacing: 0.6,
                                            ),
                                          ),
                                          Text(
                                            'now',
                                            style: GoogleFonts.inter(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500,
                                              color: DexColors.textDim,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      // Title
                                      Text(
                                        widget.title,
                                        style: GoogleFonts.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          height: 1.2,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      // Body
                                      Text(
                                        widget.body,
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: DexColors.textSecondary,
                                          height: 1.35,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Auto-dismiss progress bar
                          AnimatedBuilder(
                            animation: _progressController,
                            builder: (_, __) {
                              return Container(
                                height: 2.5,
                                alignment: Alignment.centerLeft,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(22),
                                    bottomRight: Radius.circular(22),
                                  ),
                                  color: Colors.white.withValues(alpha: 0.03),
                                ),
                                child: FractionallySizedBox(
                                  widthFactor: 1.0 - _progressController.value,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(2),
                                      gradient: LinearGradient(
                                        colors: [
                                          accent,
                                          accent.withValues(alpha: 0.4),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
