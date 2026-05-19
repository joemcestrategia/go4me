import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/models/missionary.dart';
import 'package:go4me/core/theme/app_theme.dart';

class MissionaryTimeline extends StatelessWidget {
  final MissionaryData missionary;

  const MissionaryTimeline({super.key, required this.missionary});

  @override
  Widget build(BuildContext context) {
    if (missionary.pastLocations.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            "JORNADA MISSIONÁRIA",
            style: GoogleFonts.inter(
              color: AppTheme.textSecondaryClaro,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              fontSize: 13,
            ),
          ),
        ),
        const SizedBox(height: 24),
        ...missionary.pastLocations.map((location) => _buildTimelineItem(location)),
      ],
    );
  }

  Widget _buildTimelineItem(PastLocation location) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppTheme.accentYellow,
                  shape: BoxShape.circle,
                ),
              ),
              Container(
                width: 2,
                height: 60,
                color: AppTheme.accentYellow.withValues(alpha: 0.2),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.period.toUpperCase(),
                  style: GoogleFonts.inter(
                    color: AppTheme.accentYellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${location.city}, ${location.country}",
                  style: GoogleFonts.lora(
                    color: AppTheme.textPrimaryClaro,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  location.description,
                  style: GoogleFonts.inter(
                    color: AppTheme.textSecondaryClaro,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
