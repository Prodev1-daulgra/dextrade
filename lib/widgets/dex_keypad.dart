import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/dex_colors.dart';

class DexKeypad extends StatelessWidget {
  final Function(String) onKeyPressed;
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      decoration: BoxDecoration(
        color: DexColors.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildRow(['1', '2', '3']),
          const SizedBox(height: 16),
          _buildRow(['4', '5', '6']),
          const SizedBox(height: 16),
          _buildRow(['7', '8', '9']),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKey(
                showDecimal ? '.' : '',
                onTap: showDecimal ? () => onKeyPressed('.') : null,
                isAction: !showDecimal,
              ),
              _buildKey('0'),
              _buildKey(
                '⌫',
                onTap: onBackspace,
                isAction: true,
                icon: Icons.backspace_rounded,
              ),
            ],
          ),
          if (onSubmit != null) ...[
            const SizedBox(height: 24),
            _buildSubmitButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) => _buildKey(k)).toList(),
    );
  }

  Widget _buildKey(
    String label, {
    VoidCallback? onTap,
    bool isAction = false,
    IconData? icon,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap ?? () {
          HapticFeedback.lightImpact();
          onKeyPressed(label);
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: DexColors.primary.withValues(alpha: 0.2),
        highlightColor: DexColors.primary.withValues(alpha: 0.1),
        child: Container(
          width: 80,
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isAction ? Colors.transparent : Colors.white.withValues(alpha: 0.03),
            border: Border.all(
              color: isAction ? Colors.transparent : Colors.white.withValues(alpha: 0.05),
            ),
          ),
          child: Center(
            child: icon != null
                ? Icon(icon, color: DexColors.textSecondary, size: 24)
                : Text(
                    label,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      color: isAction ? DexColors.textSecondary : Colors.white,
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
        onTap: onSubmit,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: DexColors.primaryGradient,
            ),
            boxShadow: [
              BoxShadow(
                color: DexColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              submitLabel,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
