import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/models/missionary.dart';
import 'package:go4me/core/theme/app_theme.dart';

class MissionaryStory extends StatelessWidget {
  final MissionaryData missionary;

  const MissionaryStory({super.key, required this.missionary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.borderRadius),
        border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "MINHA HISTÓRIA",
            style: GoogleFonts.inter(
              color: AppTheme.textSecondaryClaro,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            missionary.fullStory,
            style: GoogleFonts.inter(
              color: AppTheme.textPrimaryClaro,
              fontSize: 16,
              height: 1.6,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
