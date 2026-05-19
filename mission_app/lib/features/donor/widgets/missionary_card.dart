import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/models/missionary.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class MissionaryCard extends StatelessWidget {
  final MissionaryData missionary;

  const MissionaryCard({super.key, required this.missionary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/${missionary.slug}'),
      child: Container(
        width: 280,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagem de Capa com Avatar Sobreposto
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(AppTheme.borderRadius)),
                  child: Image.network(
                    missionary.coverImageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  bottom: -20,
                  left: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 24,
                      backgroundImage: NetworkImage(missionary.profileImageUrl),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    missionary.name,
                    style: GoogleFonts.lora(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryClaro,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    missionary.location,
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondaryClaro,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Barra de Progresso simplificada
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: missionary.progress,
                      backgroundColor: AppTheme.accentYellow.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentYellow),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${missionary.progressPercentage}% da meta mensal",
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimaryClaro,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
