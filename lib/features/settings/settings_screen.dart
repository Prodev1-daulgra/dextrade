import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/dex_colors.dart';
import '../../core/theme/dex_typography.dart';
import '../../providers/providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/glow_button.dart';
import '../../widgets/pulse_dot.dart';
import '../../widgets/custom_toast.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _biometricEnabled = false;
  bool _pushEnabled = true;
  bool _darkMode = true; // Always dark in Dextrade

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);
    final name = auth.user?.fullName ?? 'User';
    final email = auth.user?.email ?? '';
    final role = auth.user?.role ?? 'user';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Header ───
            Text(
              'Settings',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ).animate().fade().slideY(begin: -0.15),
            const SizedBox(height: 4),
            Text(
              'Terminal configuration & account management',
              style: DexTypography.bodySmall,
            ).animate().fade(delay: 100.ms),
            const SizedBox(height: 28),

            // ─── Profile Card ───
            _buildProfileCard(name, email, role, initial),
            const SizedBox(height: 24),

            // ─── Security Section ───
            _buildSectionLabel('SECURITY', Icons.shield_rounded),
            const SizedBox(height: 12),
            _buildToggleTile(
              icon: Icons.fingerprint_rounded,
              title: 'Biometric Authentication',
              subtitle: 'Use fingerprint or face unlock',
              value: _biometricEnabled,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _biometricEnabled = v);
                DexToast.showPushNotification(
                  context,
                  title: v ? 'Biometrics Enabled' : 'Biometrics Disabled',
                  body: v
                      ? 'Authentication secured with biometrics.'
                      : 'Biometric lock deactivated.',
                );
              },
              accentColor: DexColors.accent,
            ),
            const SizedBox(height: 8),
            _buildActionTile(
              icon: Icons.lock_reset_rounded,
              title: 'Change Password',
              subtitle: 'Update terminal access credentials',
              onTap: () => DexToast.showPushNotification(
                context,
                title: 'Coming Soon',
                body: 'Password reset module under construction.',
              ),
            ),
            const SizedBox(height: 8),
            _buildActionTile(
              icon: Icons.verified_user_rounded,
              title: 'Two-Factor Authentication',
              subtitle: 'Add an extra layer of protection',
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  color: DexColors.warning.withValues(alpha: 0.1),
                  border: Border.all(
                    color: DexColors.warning.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  'RECOMMENDED',
                  style: GoogleFonts.orbitron(
                    fontSize: 7,
                    fontWeight: FontWeight.w900,
                    color: DexColors.warning,
                  ),
                ),
              ),
              onTap: () => DexToast.showPushNotification(
                context,
                title: 'Coming Soon',
                body: '2FA setup module under construction.',
              ),
            ),
            const SizedBox(height: 28),

            // ─── Preferences Section ───
            _buildSectionLabel('PREFERENCES', Icons.tune_rounded),
            const SizedBox(height: 12),
            _buildToggleTile(
              icon: Icons.notifications_active_rounded,
              title: 'Push Notifications',
              subtitle: 'Real-time trade alerts & updates',
              value: _pushEnabled,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _pushEnabled = v);
              },
              accentColor: DexColors.primary,
            ),
            const SizedBox(height: 8),
            _buildToggleTile(
              icon: Icons.dark_mode_rounded,
              title: 'Dark Mode',
              subtitle: 'Institutional-grade display',
              value: _darkMode,
              onChanged: (_) {
                HapticFeedback.heavyImpact();
                DexToast.showPushNotification(
                  context,
                  title: 'Dark Mode Only',
                  body:
                      'Dextrade is built exclusively for the dark. No light mode available.',
                );
              },
              accentColor: DexColors.textMuted,
            ),
            const SizedBox(height: 28),

            // ─── Mobile Terminal Download ───
            _buildSectionLabel('MOBILE TERMINAL', Icons.phone_android_rounded),
            const SizedBox(height: 12),
            GlassCard(
              borderRadius: 22,
              padding: const EdgeInsets.all(20),
              borderColor: DexColors.primary.withValues(alpha: 0.2),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: DexColors.primaryGradient,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.android_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Android APK',
                              style: DexTypography.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Access on mobile',
                              style: DexTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          color: DexColors.success.withValues(alpha: 0.1),
                        ),
                        child: Text(
                          'v1.0.0',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: DexColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GlowButton(
                    label: 'Download APK',
                    icon: Icons.download_rounded,
                    width: double.infinity,
                    onPressed: () async {
                      final url = Uri.parse('/app-release.apk');
                      if (!await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      )) {
                        debugPrint('Could not launch $url');
                      }
                    },
                  ),
                ],
              ),
            ).animate().fade(delay: 400.ms),
            const SizedBox(height: 28),

            // ─── About Section ───
            _buildSectionLabel('ABOUT', Icons.info_outline_rounded),
            const SizedBox(height: 12),
            _buildInfoRow('Version', '1.0.0 (Build 1)'),
            const SizedBox(height: 6),
            _buildInfoRow('Protocol', 'Cortex V4.0'),
            const SizedBox(height: 6),
            _buildInfoRow('Engine', 'Flutter ${_getFlutterBuildInfo()}'),
            const SizedBox(height: 6),
            _buildInfoRow(
              'Status',
              'Operational',
              valueColor: DexColors.success,
            ),
            const SizedBox(height: 32),

            // ─── Sign Out ───
            GlowButton(
              label: 'Sign Out',
              isPrimary: false,
              icon: Icons.logout_rounded,
              width: double.infinity,
              onPressed: () async {
                HapticFeedback.heavyImpact();
                await ref.read(authProvider.notifier).logout();
                if (context.mounted) context.go('/landing');
              },
            ).animate().fade(delay: 500.ms),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    String name,
    String email,
    String role,
    String initial,
  ) {
    return GlassCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(24),
      borderColor: DexColors.primary.withValues(alpha: 0.15),
      child: Row(
        children: [
          // Premium avatar with glow ring
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: DexColors.primary.withValues(alpha: 0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: DexColors.primary.withValues(alpha: 0.15),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: DexColors.primaryGradient,
                  ),
                ),
                child: Center(
                  child: Text(
                    initial,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(email, style: DexTypography.caption),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: DexColors.primary.withValues(alpha: 0.1),
                    border: Border.all(
                      color: DexColors.primary.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const PulseDot(color: DexColors.primary, size: 5),
                      const SizedBox(width: 6),
                      Text(
                        role.toUpperCase(),
                        style: GoogleFonts.orbitron(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: DexColors.primary,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fade(delay: 150.ms).scale(begin: const Offset(0.96, 0.96));
  }

  Widget _buildSectionLabel(String label, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: DexColors.textMuted),
        const SizedBox(width: 8),
        Text(label, style: DexTypography.label),
      ],
    ).animate().fade(delay: 200.ms);
  }

  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    required Color accentColor,
  }) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      borderRadius: 16,
      borderColor: value
          ? accentColor.withValues(alpha: 0.15)
          : DexColors.border,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(11),
              color: accentColor.withValues(alpha: value ? 0.12 : 0.06),
            ),
            child: Icon(
              icon,
              size: 18,
              color: accentColor.withValues(alpha: value ? 1.0 : 0.5),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: DexTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(subtitle, style: DexTypography.caption),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: accentColor,
            inactiveTrackColor: DexColors.surfaceLight,
          ),
        ],
      ),
    ).animate().fade(delay: 250.ms);
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        borderRadius: 16,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(11),
                color: DexColors.surfaceLight,
              ),
              child: Icon(icon, size: 18, color: DexColors.textSecondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DexTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(subtitle, style: DexTypography.caption),
                ],
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: DexColors.textMuted,
                ),
          ],
        ),
      ),
    ).animate().fade(delay: 250.ms);
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: DexTypography.caption),
        Text(
          value,
          style: GoogleFonts.jetBrainsMono(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: valueColor ?? DexColors.textSecondary,
          ),
        ),
      ],
    );
  }

  String _getFlutterBuildInfo() {
    return '3.x'; // Will be replaced by real build info in production
  }
}
