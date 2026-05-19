import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/theme/app_theme.dart';

class GamificationBadge extends StatelessWidget {
  final bool isMonthly;
  final int amount;

  const GamificationBadge({
    super.key,
    required this.isMonthly,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    if (!isMonthly) return const SizedBox.shrink();

    // Determine Level
    String level = "Semente";
    IconData icon = Icons.spa;
    Color color = AppTheme.primaryGreen;
    String description = "Você está plantando o futuro.";

    if (amount >= 500) {
      level = "Provedor";
      icon = Icons.volunteer_activism;
      color = Colors.amber;
      description = "Sua generosidade transforma realidades inteiras.";
    } else if (amount >= 100) {
      level = "Cultivador";
      icon = Icons.water_drop;
      color = Colors.blueAccent;
      description = "Seu apoio constante faz a missão florescer.";
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28)
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  duration: 1.seconds,
                  begin: const Offset(1, 1),
                  end: const Offset(1.1, 1.1),
                )
                .shimmer(delay: 2.seconds, duration: 1.seconds),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "NÍVEL: $level".toUpperCase(),
                  style: GoogleFonts.rubik(
                    fontWeight: FontWeight.bold,
                    color: color,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ).animate().fadeIn().slideX(begin: -0.2),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textDark,
                  ),
                ).animate().fadeIn(delay: 200.ms),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn().scale();
  }
}
