import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CryptoIcon extends StatelessWidget {
  final String symbol;
  final double size;
  final String? colorHex;
  final String? imageUrl;

  const CryptoIcon({
    super.key,
    required this.symbol,
    this.size = 32,
    this.colorHex,
    this.imageUrl,
  });

  Color _getColor() {
    if (colorHex != null && colorHex!.isNotEmpty) {
      try {
        final hex = colorHex!.replaceAll('#', '');
        return Color(int.parse('FF$hex', radix: 16));
      } catch (_) {
        // Fallback
      }
    }
    
    // Default colors for common cryptos
    switch (symbol.toUpperCase()) {
      case 'BTC': return const Color(0xFFF7931A);
      case 'ETH': return const Color(0xFF627EEA);
      case 'SOL': return const Color(0xFF14F195);
      case 'USDT': return const Color(0xFF26A17B);
      case 'USDC': return const Color(0xFF2775CA);
      case 'BNB': return const Color(0xFFF3BA2F);
      case 'XRP': return const Color(0xFF23292F);
      case 'ADA': return const Color(0xFF0033AD);
      case 'DOGE': return const Color(0xFFC2A633);
      case 'DOT': return const Color(0xFFE6007A);
      default:
        // Generate pseudo-random color based on symbol hash
        final hash = symbol.codeUnits.fold<int>(0, (prev, curr) => prev + curr);
        final hue = (hash * 137.5) % 360;
        return HSLColor.fromAHSL(1.0, hue, 0.7, 0.6).toColor();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          image: DecorationImage(
            image: NetworkImage(imageUrl!),
            fit: BoxFit.cover,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: size / 4,
            ),
          ],
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: size / 4,
          ),
        ],
      ),
      child: Center(
        child: Text(
          symbol.isNotEmpty ? symbol.substring(0, 1).toUpperCase() : '?',
          style: GoogleFonts.inter(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.45,
          ),
        ),
      ),
    );
  }
}
