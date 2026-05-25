import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/dex_colors.dart';

/// Branded trading numpad — glow keys, haptics, gradient confirm rail.
class DexKeypad extends StatelessWidget {
  final void Function(String) onKeyPressed;
  final VoidCallback onBackspace;
  final VoidCallback? onSubmit;
  final String submitLabel;
  final bool showDecimal;

  const DexKeypad({
    super.key,
    required this.onKeyPressed,
    required this.onBackspace,
    this.onSubmit,
    this.submitLabel = 'CONFIRM',
    this.showDecimal = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF08050F),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        border: Border(
          top: BorderSide(color: DexColors.primary.withValues(alpha: 0.25)),
        ),
        boxShadow: [
          BoxShadow(
            color: DexColors.primary.withValues(alpha: 0.12),
            blurRadius: 40,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 44,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Row(
              children: [
                Icon(
                  Icons.dialpad_rounded,
                  size: 16,
                  color: DexColors.primary.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 8),
                Text(
                  'DEX KEYPAD',
                  style: GoogleFonts.orbitron(
                    fontSize: 9,
                    letterSpacing: 2,
                    fontWeight: FontWeight.w900,
                    color: DexColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Column(
              children: [
                _buildRow(['1', '2', '3']),
                const SizedBox(height: 10),
                _buildRow(['4', '5', '6']),
                const SizedBox(height: 10),
                _buildRow(['7', '8', '9']),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildKey(
                      showDecimal ? '.' : '',
                      onTap: showDecimal ? () => onKeyPressed('.') : null,
                      isGhost: !showDecimal,
                    ),
                    _buildKey('0'),
                    _buildKey(
                      '',
                      onTap: onBackspace,
                      isAction: true,
                      icon: Icons.backspace_outlined,
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onSubmit != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: _buildSubmitButton(),
            ),
          ] else
            const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map(_buildKey).toList(),
    );
  }

  Widget _buildKey(
    String label, {
    VoidCallback? onTap,
    bool isAction = false,
    bool isGhost = false,
    IconData? icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ??
            (isGhost
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onKeyPressed(label);
                  }),
        borderRadius: BorderRadius.circular(18),
        splashColor: DexColors.primary.withValues(alpha: 0.2),
        child: Ink(
          width: 76,
          height: 58,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: isAction || isGhost
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.07),
                      Colors.white.withValues(alpha: 0.02),
                    ],
                  ),
            border: Border.all(
              color: isAction
                  ? Colors.transparent
                  : DexColors.primary.withValues(alpha: 0.12),
            ),
            boxShadow: isAction
                ? null
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: DexColors.textSecondary, size: 22)
                : Text(
                    label,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: isGhost ? Colors.transparent : Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onSubmit?.call();
        },
        borderRadius: BorderRadius.circular(18),
        child: Ink(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: const LinearGradient(colors: DexColors.primaryGradient),
            boxShadow: [
              BoxShadow(
                color: DexColors.primary.withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              submitLabel,
              style: GoogleFonts.orbitron(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
