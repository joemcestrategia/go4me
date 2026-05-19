import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/features/donor/data/feed_provider.dart';

class DonorProfileTab extends ConsumerWidget {
  const DonorProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(feedProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          "Meu Perfil",
          style: GoogleFonts.inter(
            color: AppTheme.textPrimaryClaro,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: AppTheme.textPrimaryClaro),
            onPressed: () {},
          ),
        ],
      ),
      body: feedAsync.when(
        data: (posts) {
          final likedCount = posts.where((p) => p.isLiked).length;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildProfileCard(likedCount),
                const SizedBox(height: 20),
                _buildSectionTitle("Missionários que Apoio", Icons.favorite),
                const SizedBox(height: 12),
                _buildPlaceholderCard("João Paulo", "Santiago, Chile"),
                const SizedBox(height: 20),
                _buildSectionTitle("Resumo de Doações", Icons.volunteer_activism),
                const SizedBox(height: 12),
                _buildDonationSummary(),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Erro ao carregar perfil: $err")),
      ),
    );
  }

  Widget _buildProfileCard(int likedCount) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              const CircleAvatar(
                radius: 46,
                backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150&h=150&fit=crop'),
              ),
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppTheme.accentYellow,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    size: 14, color: AppTheme.textPrimaryClaro),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            "Doador Mission",
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w800,
              fontSize: 20,
              color: AppTheme.textPrimaryClaro,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "Doador desde Jan 2024",
            style: GoogleFonts.inter(
                color: AppTheme.textSecondaryClaro, fontSize: 13),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStat("12", "Doações\nRealizadas"),
                _buildDivider(),
                _buildStat("$likedCount", "Posts\nCurtidos"),
                _buildDivider(),
                _buildStat("3", "Missionários\nApoiados"),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w800,
            fontSize: 20,
            color: AppTheme.textPrimaryClaro,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.inter(
            color: AppTheme.textSecondaryClaro,
            fontSize: 11,
            height: 1.3,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() => Container(
        width: 1,
        height: 32,
        color: const Color(0xFFE5E7EB),
      );

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppTheme.accentYellowLight,
            borderRadius: BorderRadius.circular(AppTheme.radiusXS),
          ),
          child: Icon(icon, color: AppTheme.accentYellowDark, size: 17),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: AppTheme.textPrimaryClaro,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderCard(String name, String sub) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppTheme.accentYellowLight,
            child: const Icon(Icons.person_rounded,
                color: AppTheme.accentYellowDark, size: 22),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimaryClaro,
                ),
              ),
              Text(
                sub,
                style: GoogleFonts.inter(
                    color: AppTheme.textSecondaryClaro, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDonationSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          _buildRow("Total Contribuído", "R\$ 1.250,00"),
          const Divider(height: 24),
          _buildRow("Impacto Direto", "10 Vidas"),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: AppTheme.textSecondaryClaro,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimaryClaro,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
