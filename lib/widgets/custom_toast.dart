import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/theme/dex_colors.dart';
import '../core/theme/dex_typography.dart';
import 'dart:async';

enum ToastType { success, error, info }

class DexToast {
  static void show(BuildContext context, String message, {ToastType type = ToastType.info}) {
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

  static void showPushNotification(BuildContext context, {required String title, required String body}) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _PushNotificationWidget(
        title: title,
        body: body,
        onDismiss: () => entry.remove(),
      ),
    );

    overlay.insert(entry);
  }
}

class _ToastWidget extends StatefulWidget {
  final String message;
  final ToastType type;
  final VoidCallback onDismiss;

  const _ToastWidget({required this.message, required this.type, required this.onDismiss});

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
      default:
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: DexColors.surfaceLight.withValues(alpha: 0.95),
                  border: Border.all(color: accentColor.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(color: accentColor.withValues(alpha: 0.1), blurRadius: 20, spreadRadius: -5, offset: const Offset(0, 10)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, color: accentColor, size: 24)
                        .animate(onPlay: (controller) => controller.repeat())
                        .shimmer(duration: 2000.ms, color: accentColor.withValues(alpha: 0.5)),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        widget.message,
                        style: DexTypography.bodyMedium.copyWith(color: DexColors.textPrimary, fontWeight: FontWeight.w600),
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
      return child.animate().slideY(begin: 0, end: -1, duration: 300.ms, curve: Curves.easeIn).fadeOut(duration: 300.ms);
    } else {
      return child.animate().slideY(begin: -1, end: 0, duration: 400.ms, curve: Curves.easeOutBack).fadeIn(duration: 400.ms);
    }
  }
}

class _PushNotificationWidget extends StatefulWidget {
  final String title;
  final String body;
  final VoidCallback onDismiss;

  const _PushNotificationWidget({required this.title, required this.body, required this.onDismiss});

  @override
  State<_PushNotificationWidget> createState() => _PushNotificationWidgetState();
}

class _PushNotificationWidgetState extends State<_PushNotificationWidget> {
  bool _dismissing = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 5), _startDismiss);
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
    final child = SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _startDismiss,
              onPanUpdate: (details) {
                if (details.delta.dy < -5) _startDismiss();
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: const Color(0xFF1A1A24).withValues(alpha: 0.95), // Deeper iOS style color
                  boxShadow: [
                    BoxShadow(color: Colors.black.withValues(alpha: 0.5), blurRadius: 30, spreadRadius: -5, offset: const Offset(0, 15)),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // App Icon Avatar
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [DexColors.primary, DexColors.primary.withValues(alpha: 0.6)]),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text('D', style: DexTypography.h3.copyWith(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    // Notification Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('DEXTRADE', style: DexTypography.label.copyWith(color: DexColors.textMuted, fontSize: 12)),
                              Text('now', style: DexTypography.label.copyWith(color: DexColors.textMuted, fontSize: 12)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.title,
                            style: DexTypography.bodyLarge.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.body,
                            style: DexTypography.bodyMedium.copyWith(color: DexColors.textSecondary),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
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
      return child.animate().slideY(begin: 0, end: -1, duration: 300.ms, curve: Curves.easeIn).fadeOut(duration: 300.ms);
    } else {
      return child.animate().slideY(begin: -1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
    }
  }
}
