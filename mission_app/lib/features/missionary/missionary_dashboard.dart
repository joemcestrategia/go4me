import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/models/missionary.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go4me/core/providers/data_providers.dart';
import 'package:go4me/core/data/mock_repository.dart';

class MissionaryDashboard extends ConsumerWidget {
  const MissionaryDashboard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionaryAsync = ref.watch(currentMissionaryProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: missionaryAsync.when(
        data: (missionary) {
          final m = missionary ?? MockRepository.allMissionaries.first;
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFFF8D6), AppTheme.background]),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 56, 24, 24),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text("Bom dia,", style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textSecondaryClaro)),
                      const SizedBox(height: 2),
                      Text(m.name.split(' ').first, style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimaryClaro, letterSpacing: -0.5)),
                    ]),
                    CircleAvatar(radius: 24, backgroundImage: NetworkImage(m.profileImageUrl), onBackgroundImageError: (_, __) {}, backgroundColor: AppTheme.accentYellowLight),
                  ]),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildMainSupportCard(m).animate().fadeIn().slideY(begin: 0.06),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(child: _buildStatCard(label: "Novos Semeadores", value: "+${m.recentDonors.length}", icon: FontAwesomeIcons.users, iconColor: AppTheme.accentYellow)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildStatCard(label: "Meta Mensal", value: "${((m.currentSupport / m.goalSupport) * 100).toStringAsFixed(0)}%", icon: FontAwesomeIcons.bullseye, iconColor: AppTheme.successGreen)),
                    ]).animate().fadeIn(delay: 100.ms).slideY(begin: 0.06),
                    const SizedBox(height: 28),
                    _buildSectionTitle("Ferramenta de Gratidão"),
                    const SizedBox(height: 14),
                    _buildGratitudeSection(context, m).animate().fadeIn(delay: 200.ms),
                  ]),
                ),
              ),
            ],
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: AppTheme.accentYellow, strokeWidth: 2.5)),
        error: (err, _) => Center(child: Text("Erro: $err", style: GoogleFonts.inter(color: AppTheme.textSecondaryClaro))),
      ),
    );
  }

  Widget _buildMainSupportCard(MissionaryData missionary) {
    final progress = (missionary.currentSupport / missionary.goalSupport).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(AppTheme.radiusXL), boxShadow: AppTheme.darkCardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text("Suporte Mensal", style: GoogleFonts.inter(color: AppTheme.textSecondaryEscuro, fontWeight: FontWeight.w500, fontSize: 13, letterSpacing: 0.2)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.accentYellow.withOpacity(0.15), borderRadius: BorderRadius.circular(20)),
            child: Text("${(progress * 100).toStringAsFixed(0)}% da meta", style: GoogleFonts.inter(color: AppTheme.accentYellow, fontSize: 11, fontWeight: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 14),
        Text("R\$ ${missionary.currentSupport.toStringAsFixed(0)}", style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.w900, color: AppTheme.accentYellow, letterSpacing: -1)),
        const SizedBox(height: 6),
        Text("meta: R\$ ${missionary.goalSupport.toStringAsFixed(0)} / mês", style: GoogleFonts.inter(color: AppTheme.textSecondaryEscuro, fontSize: 13)),
        const SizedBox(height: 22),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(value: progress, minHeight: 8, backgroundColor: Colors.white.withOpacity(0.1), valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.accentYellow)),
        ),
        const SizedBox(height: 20),
        Row(children: [
          _buildMiniStat("${missionary.recentDonors.length}", "semeadores ativos"),
          const SizedBox(width: 28),
          _buildMiniStat(missionary.location, "campo"),
        ]),
      ]),
    );
  }

  Widget _buildMiniStat(String value, String label) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(value, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondaryEscuro)),
    ]);
  }

  Widget _buildStatCard({required String label, required String value, required IconData icon, required Color iconColor}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(AppTheme.radiusXL), boxShadow: AppTheme.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 40, height: 40, decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.radiusSM)), child: Center(child: FaIcon(icon, size: 17, color: iconColor))),
        const SizedBox(height: 14),
        Text(value, style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimaryClaro, letterSpacing: -0.5)),
        const SizedBox(height: 3),
        Text(label, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondaryClaro)),
      ]),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryClaro, letterSpacing: -0.2));
  }

  Widget _buildGratitudeSection(BuildContext context, MissionaryData missionary) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(AppTheme.radiusXL), boxShadow: AppTheme.cardShadow),
      child: missionary.recentDonors.isNotEmpty
          ? ListView.separated(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              itemCount: missionary.recentDonors.length,
              separatorBuilder: (_, __) => const Divider(height: 1, indent: 72, endIndent: 20),
              itemBuilder: (context, index) => _buildDonorItem(context, missionary.recentDonors[index]),
            )
          : Padding(
              padding: const EdgeInsets.all(28),
              child: Column(children: [
                Icon(Icons.volunteer_activism_rounded, size: 40, color: AppTheme.accentYellowLight),
                const SizedBox(height: 12),
                Text("Sem novos semeadores no momento.", style: GoogleFonts.inter(color: AppTheme.textSecondaryClaro, fontSize: 14)),
              ]),
            ),
    );
  }

  Widget _buildDonorItem(BuildContext context, Donor donor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      child: Row(children: [
        CircleAvatar(radius: 22, backgroundImage: NetworkImage(donor.avatarUrl), onBackgroundImageError: (_, __) {}, backgroundColor: AppTheme.accentYellowLight),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(donor.name, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimaryClaro)),
            const SizedBox(height: 2),
            Text("Semeou R\$ ${donor.amount.toStringAsFixed(0)}", style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondaryClaro)),
          ]),
        ),
        GestureDetector(
          onTap: () => _launchWhatsApp(context, donor),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(color: AppTheme.accentYellow, borderRadius: BorderRadius.circular(20)),
            child: Text("Agradecer", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryClaro)),
          ),
        ),
      ]),
    );
  }

  void _launchWhatsApp(BuildContext context, Donor donor) async {
    final message = Uri.encodeComponent("Olá ${donor.name.split(' ').first}! Muito obrigado por se tornar um parceiro da nossa missão. Seu apoio de R\$ ${donor.amount} faz toda a diferença! Deus abençoe.");
    final url = Uri.parse("https://wa.me/?text=$message");
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Não foi possível abrir o WhatsApp")));
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erro: $e")));
      }
    }
  }
}
