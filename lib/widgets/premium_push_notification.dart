import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/dex_colors.dart';
import 'glass_card.dart';

class PremiumPushNotification extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;

  const PremiumPushNotification({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? DexColors.primary;
    
    return GestureDetector(
      onTap: onTap,
      child: SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 20,
            borderColor: themeColor.withValues(alpha: 0.3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Glowing Icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: themeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: themeColor.withValues(alpha: 0.2),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(icon, color: themeColor, size: 22),
                  ),
                ),
                const SizedBox(width: 16),
                
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        message,
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: DexColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static void show(BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    Color? color,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;
    
    entry = OverlayEntry(
      builder: (context) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          builder: (context, value, child) {
            return Positioned(
              top: -100 + (100 * value),
              left: 0,
              right: 0,
              child: Opacity(
                opacity: value.clamp(0.0, 1.0),
                child: child,
              ),
            );
          },
          child: PremiumPushNotification(
            title: title,
            message: message,
            icon: icon,
            color: color,
            onTap: () {
              entry.remove();
              if (onTap != null) onTap();
            },
          ),
        );
      },
    );

    overlay.insert(entry);
    
    Future.delayed(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });
  }
}
