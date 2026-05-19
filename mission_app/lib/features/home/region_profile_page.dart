import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/services/joshua_project_service.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/core/providers/data_providers.dart';
import 'package:go4me/features/landing/missionary_page.dart';
import 'package:go4me/core/models/missionary.dart';

class RegionProfilePage extends ConsumerWidget {
  final JoshuaCountry? country;

  const RegionProfilePage({super.key, this.country});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (country == null) {
      return const Scaffold(body: Center(child: Text("País não encontrado.")));
    }

    final missionariesAsync = ref.watch(allMissionariesProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickStats(),
                  const SizedBox(height: 32),
                  _buildMissionariesList(context, missionariesAsync),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.surfaceDark,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          country!.name.toUpperCase(),
          style: GoogleFonts.lora(
            fontWeight: FontWeight.bold,
            letterSpacing: 2,
            color: AppTheme.accentYellow,
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (country!.iso2code.isNotEmpty)
              Image.network(
                "https://flagcdn.com/w640/${country!.iso2code.toLowerCase()}.png",
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(color: AppTheme.surfaceDark),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppTheme.surfaceDark.withValues(alpha: 0.8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("População", "${(country!.population / 1000000).toStringAsFixed(1)}M"),
          _buildStatItem("Povos", "${country!.numPeopleGroups}"),
          _buildStatItem("Cristãos", "${country!.percentChristianity.toStringAsFixed(1)}%"),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: AppTheme.textPrimaryClaro,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textSecondaryClaro,
          ),
        ),
      ],
    );
  }

  Widget _buildMissionariesList(BuildContext context, AsyncValue<List<MissionaryData>> missionariesAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "MISSIONÁRIOS NESTA REGIÃO",
          style: GoogleFonts.inter(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            fontSize: 14,
            color: AppTheme.textPrimaryClaro,
          ),
        ),
        const SizedBox(height: 16),
        missionariesAsync.when(
          data: (missionaries) {
            // No futuro, filtrar por countryCode
            final countryMissionaries = missionaries;
            
            if (countryMissionaries.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Text("Ainda não temos missionários parceiros nesta região."),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: countryMissionaries.length,
              itemBuilder: (context, index) {
                final missionary = countryMissionaries[index];
                return _buildMissionaryCard(context, missionary);
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Text("Erro ao carregar missionários: $err"),
        ),
      ],
    );
  }

  Widget _buildMissionaryCard(BuildContext context, MissionaryData missionary) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MissionaryPage(slug: missionary.slug),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: NetworkImage(missionary.profileImageUrl),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    missionary.name,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    missionary.headline,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: AppTheme.textSecondaryClaro),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.accentYellow),
          ],
        ),
      ),
    );
  }
}
