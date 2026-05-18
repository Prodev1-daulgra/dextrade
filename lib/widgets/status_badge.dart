import 'package:flutter/material.dart';
import '../../core/theme/dex_colors.dart';

class StatusBadge extends StatefulWidget {
  final String status;
  final double? fontSize;

  const StatusBadge({super.key, required this.status, this.fontSize});

  @override
  State<StatusBadge> createState() => _StatusBadgeState();
}

class _StatusBadgeState extends State<StatusBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.status == 'pending') {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StatusBadge old) {
    super.didUpdateWidget(old);
    if (widget.status == 'pending') {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final config = _getConfig(widget.status);
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: config.color.withValues(
              alpha: 0.12 + _pulseController.value * 0.08,
            ),
            border: Border.all(
              color: config.color.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: config.color,
                  boxShadow: [
                    BoxShadow(
                      color: config.color.withValues(alpha: 0.5),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Text(
                config.label.toUpperCase(),
                style: TextStyle(
                  fontSize: widget.fontSize ?? 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: config.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  _StatusConfig _getConfig(String status) {
    switch (status) {
      case 'approved':
      case 'completed':
        return _StatusConfig('Successful', DexColors.success);
      case 'rejected':
        return _StatusConfig('Failed', DexColors.error);
      case 'pending':
        return _StatusConfig('Confirming', DexColors.warning);
      default:
        return _StatusConfig(status, DexColors.textMuted);
    }
  }
}

class _StatusConfig {
  final String label;
  final Color color;
  _StatusConfig(this.label, this.color);
}
