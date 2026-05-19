import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/theme/app_theme.dart';

class BadgesGrid extends StatelessWidget {
  const BadgesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          "Minhas Conquistas",
          style: GoogleFonts.rubik(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
      ),
      body: _buildGrid(context),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final badges = [
      {
        "name": "Semente",
        "icon": Icons.spa,
        "color": Colors.green,
        "unlocked": true,
      },
      {
        "name": "Cultivador",
        "icon": Icons.water_drop,
        "color": Colors.blue,
        "unlocked": true,
      },
      {
        "name": "Provedor",
        "icon": Icons.volunteer_activism,
        "color": Colors.amber,
        "unlocked": false,
      },
      {
        "name": "Embaixador",
        "icon": Icons.public,
        "color": Colors.purple,
        "unlocked": false,
      },
    ];

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.85,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        final isUnlocked = badge['unlocked'] as bool;

        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isUnlocked
                  ? (badge['color'] as Color).withValues(alpha: 0.3)
                  : Colors.grey[200]!,
            ),
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: (badge['color'] as Color).withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? (badge['color'] as Color).withValues(alpha: 0.1)
                      : Colors.grey[100],
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(
                          badge['icon'] as IconData,
                          size: 40,
                          color: isUnlocked
                              ? badge['color'] as Color
                              : Colors.grey[400],
                        )
                        .animate(target: isUnlocked ? 1 : 0)
                        .shimmer(
                          duration: 2.seconds,
                          delay: 1.seconds,
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
              ),
              const SizedBox(height: 16),
              Text(
                (badge['name'] as String).toUpperCase(),
                style: GoogleFonts.rubik(
                  fontWeight: FontWeight.bold,
                  color: isUnlocked ? AppTheme.textDark : Colors.grey[400],
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              if (!isUnlocked)
                const Text(
                  "Bloqueado",
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
            ],
          ),
        ).animate().scale(delay: (100 * index).ms);
      },
    );
  }
}
