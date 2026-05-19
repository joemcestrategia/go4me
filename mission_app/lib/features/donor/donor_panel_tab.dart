import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go4me/core/providers/data_providers.dart';
import 'package:go4me/core/data/mock_repository.dart';
import 'package:go4me/core/models/missionary.dart';

class DonorPanelTab extends ConsumerWidget {
  const DonorPanelTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final donorAsync = ref.watch(currentDonorProvider);
    final missionariesAsync = ref.watch(allMissionariesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF8D6), AppTheme.background],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Meu Impacto',
                      style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimaryClaro, letterSpacing: -0.5)),
                  const SizedBox(height: 4),
                  Text('Veja como suas semeaduras estão transformando vidas.',
                      style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondaryClaro)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                donorAsync.when(
                  data: (donor) => Row(children: [
                    Expanded(child: _buildImpactCard('Total Doado', 'R\$ ${donor?.totalDonated?.toStringAsFixed(0) ?? '0'}', FontAwesomeIcons.handHoldingHeart, AppTheme.accentYellow)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildImpactCard('Missões', '${donor?.supportedMissionsCount ?? 0}', FontAwesomeIcons.globe, AppTheme.successGreen)),
                  ]),
                  loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                  error: (_, __) => Row(children: [
                    Expanded(child: _buildImpactCard('Total Doado', 'R\$ 0', FontAwesomeIcons.handHoldingHeart, AppTheme.accentYellow)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildImpactCard('Missões', '0', FontAwesomeIcons.globe, AppTheme.successGreen)),
                  ]),
                ),
                const SizedBox(height: 12),
                _buildImpactCard('Vidas Alcançadas (Est.)', '5.2M+', FontAwesomeIcons.earthAmericas, const Color(0xFF6366F1), isFullWidth: true),
                const SizedBox(height: 28),
                Text('Missionários em Destaque',
                    style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryClaro, letterSpacing: -0.2)),
                const SizedBox(height: 14),
                missionariesAsync.when(
                  data: (missionaries) {
                    final display = missionaries.take(5).toList();
                    return Column(
                      children: display.map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildMissionaryCard(m),
                      )).toList(),
                    );
                  },
                  loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                  error: (_, __) {
                    final fallback = MockRepository.allMissionaries.take(5).toList();
                    return Column(
                      children: fallback.map((m) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildMissionaryCard(m),
                      )).toList(),
                    );
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.search_rounded, size: 18),
                    label: Text('Encontrar Mais Missões', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.textPrimaryClaro,
                      side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXL)),
                    ),
                  ),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactCard(String label, String value, IconData icon, Color iconColor, {bool isFullWidth = false}) {
    return Container(
      width: isFullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(AppTheme.radiusXL), boxShadow: AppTheme.cardShadow),
      child: isFullWidth
          ? Row(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusSM)),
                child: Center(child: FaIcon(icon, size: 20, color: iconColor)),
              ),
              const SizedBox(width: 16),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(value, style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.textPrimaryClaro, letterSpacing: -0.5)),
                Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondaryClaro)),
              ]),
            ])
          : Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(
                width: 40, height: 40,
                decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusSM)),
                child: Center(child: FaIcon(icon, size: 17, color: iconColor)),
              ),
              const SizedBox(height: 14),
              Text(value, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimaryClaro, letterSpacing: -0.5)),
              const SizedBox(height: 3),
              Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondaryClaro)),
            ]),
    );
  }

  Widget _buildMissionaryCard(MissionaryData m) {
    final progress = (m.currentSupport / m.goalSupport).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(AppTheme.radiusXL), boxShadow: AppTheme.cardShadow),
      child: Row(children: [
        CircleAvatar(radius: 24, backgroundImage: NetworkImage(m.profileImageUrl), backgroundColor: AppTheme.accentYellowLight),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(m.name, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimaryClaro)),
            const SizedBox(height: 2),
            Text(m.location, style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondaryClaro)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: progress, minHeight: 4,
                  backgroundColor: AppTheme.accentYellowLight, valueColor: const AlwaysStoppedAnimation(AppTheme.accentYellow)),
            ),
          ]),
        ),
        Text('${(m.progress * 100).toInt()}%',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.accentYellowDark)),
      ]),
    );
  }
}
