import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go4me/core/models/missionary.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/shared/widgets/responsive_layout.dart';
import 'package:go4me/features/landing/widgets/missionary_hero.dart';
import 'package:go4me/features/landing/widgets/missionary_story.dart';
import 'package:go4me/features/donation/widgets/donation_widget.dart';
import 'package:go4me/features/landing/widgets/missionary_timeline.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/providers/data_providers.dart';

class MissionaryPage extends ConsumerWidget {
  final String slug;

  const MissionaryPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionaryAsyncValue = ref.watch(missionaryBySlugProvider(slug));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: missionaryAsyncValue.when(
        data: (missionary) {
          if (missionary == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off_rounded, size: 64, color: AppTheme.textTertiaryClaro),
                  const SizedBox(height: 16),
                  Text('Missionário não encontrado',
                      style: GoogleFonts.inter(fontSize: 16, color: AppTheme.textSecondaryClaro)),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Voltar', style: GoogleFonts.inter(color: AppTheme.accentYellow)),
                  ),
                ],
              ),
            );
          }
          return ResponsiveLayout(
            mobile: _buildMobileLayout(context, missionary),
            desktop: _buildDesktopLayout(context, missionary),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: AppTheme.accentYellow, strokeWidth: 2.5)),
        error: (err, _) => Center(
          child: Text('Erro ao carregar: $err',
              style: GoogleFonts.inter(color: AppTheme.textSecondaryClaro)),
        ),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context, MissionaryData missionary) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: MissionaryHero(missionary: missionary, isDesktop: false)),
        SliverPadding(
          padding: const EdgeInsets.all(20),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              MissionaryStory(missionary: missionary),
              const SizedBox(height: 32),
              DonationWidget(missionary: missionary),
              const SizedBox(height: 32),
              if (missionary.oneTimeProjects.isNotEmpty) ...[
                _buildSectionTitle('PROJETOS ATUAIS'),
                const SizedBox(height: 16),
                ...missionary.oneTimeProjects.map((p) => _buildProjectCard(p)),
                const SizedBox(height: 24),
              ],
              MissionaryTimeline(missionary: missionary),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context, MissionaryData missionary) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: MissionaryHero(missionary: missionary, isDesktop: true)),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
          sliver: SliverToBoxAdapter(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MissionaryStory(missionary: missionary),
                      const SizedBox(height: 48),
                      if (missionary.oneTimeProjects.isNotEmpty) ...[
                        _buildSectionTitle('PROJETOS ATUAIS'),
                        const SizedBox(height: 24),
                        ...missionary.oneTimeProjects.map((p) => _buildProjectCard(p)),
                      ],
                      const SizedBox(height: 48),
                      MissionaryTimeline(missionary: missionary),
                    ],
                  ),
                ),
                const SizedBox(width: 48),
                Expanded(
                  flex: 1,
                  child: StickyDonationCard(missionary: missionary),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String text) {
    return Text(text, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppTheme.textPrimaryClaro));
  }

  Widget _buildProjectCard(Project project) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(child: Text(project.title, style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimaryClaro))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppTheme.accentYellowLight, borderRadius: BorderRadius.circular(20)),
            child: Text("${project.progressPercentage}%", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.accentYellowDark)),
          ),
        ]),
        const SizedBox(height: 10),
        Text(project.description, style: GoogleFonts.inter(color: AppTheme.textSecondaryClaro, fontSize: 14, height: 1.5)),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: project.progress,
            minHeight: 8,
            backgroundColor: AppTheme.accentYellowLight,
            valueColor: const AlwaysStoppedAnimation(AppTheme.accentYellow),
          ),
        ),
      ]),
    );
  }
}

class StickyDonationCard extends StatelessWidget {
  final MissionaryData missionary;
  const StickyDonationCard({super.key, required this.missionary});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      DonationWidget(missionary: missionary),
      const SizedBox(height: 24),
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.darkCardShadow),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.security, color: AppTheme.accentYellow, size: 32),
          const SizedBox(height: 16),
          Text("DOAÇÃO SEGURA", style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: Colors.white, fontSize: 13, letterSpacing: 1)),
          const SizedBox(height: 8),
          Text("Processada com criptografia via Stripe. Sua contribuição vai diretamente para a missão.",
              style: GoogleFonts.inter(color: AppTheme.textSecondaryEscuro, fontSize: 13, height: 1.5)),
        ]),
      ),
    ]);
  }
}
