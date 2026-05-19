import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/core/providers/data_providers.dart';
import 'package:go4me/features/missionary/edit_profile_page.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

final profileVisibilityProvider = StateProvider<bool>((ref) {
  final missionary = ref.watch(currentMissionaryProvider);
  return missionary.maybeWhen(
    data: (data) => data?.isPublic ?? true,
    orElse: () => true,
  );
});

class MissionaryProfileTab extends ConsumerWidget {
  const MissionaryProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missionaryAsync = ref.watch(currentMissionaryProvider);
    final isPublic = ref.watch(profileVisibilityProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text("Meu Perfil", style: GoogleFonts.inter(color: AppTheme.textPrimaryClaro, fontWeight: FontWeight.w700, fontSize: 18)),
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const EditProfilePage()),
              );
            },
            icon: const Icon(Icons.edit_outlined, size: 17),
            label: Text("Editar", style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
            style: TextButton.styleFrom(foregroundColor: AppTheme.textPrimaryClaro),
          ),
        ],
      ),
      body: missionaryAsync.when(
        data: (missionary) {
          if (missionary == null) {
            return Center(child: Text("Perfil não encontrado", style: GoogleFonts.inter(color: AppTheme.textSecondaryClaro)));
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(children: [
              _buildProfileCard(missionary),
              const SizedBox(height: 16),
              _buildVisibilityToggle(isPublic, ref),
              const SizedBox(height: 16),
              _buildStripeCard(context),
              const SizedBox(height: 16),
              _buildInfoSection("Informações", [
                _InfoItem(Icons.flag, "Nacionalidade", missionary.nationality),
                _InfoItem(Icons.calendar_today, "No Campo", "${missionary.yearsInField}"),
                _InfoItem(Icons.people, "Vidas Impactadas", missionary.livesImpacted),
              ]),
              const SizedBox(height: 16),
              _buildInfoSection("Financeiro", [
                _InfoItem(Icons.trending_up, "Suporte Mensal", "R\$ ${missionary.currentSupport.toStringAsFixed(0)}"),
                _InfoItem(Icons.flag_circle, "Meta", "R\$ ${missionary.goalSupport.toStringAsFixed(0)}"),
                _InfoItem(Icons.percent, "% Alcançado", "${(missionary.currentSupport / missionary.goalSupport * 100).toStringAsFixed(0)}%"),
              ]),
            ]),
          );
        },
        loading: () => Center(child: CircularProgressIndicator(color: AppTheme.accentYellow, strokeWidth: 2.5)),
        error: (err, _) => Center(child: Text("Erro: $err", style: GoogleFonts.inter(color: AppTheme.textSecondaryClaro))),
      ),
    );
  }

  Widget _buildProfileCard(dynamic missionary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(AppTheme.radiusXL), boxShadow: AppTheme.cardShadow),
      child: Column(children: [
        Stack(alignment: Alignment.bottomRight, children: [
          CircleAvatar(radius: 50, backgroundImage: NetworkImage(missionary.profileImageUrl), onBackgroundImageError: (_, __) {}, backgroundColor: AppTheme.accentYellowLight),
          Container(width: 28, height: 28, decoration: const BoxDecoration(color: AppTheme.accentYellow, shape: BoxShape.circle), child: const Icon(Icons.camera_alt_rounded, size: 14, color: AppTheme.textPrimaryClaro)),
        ]),
        const SizedBox(height: 16),
        Text(missionary.name, style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimaryClaro, letterSpacing: -0.3)),
        const SizedBox(height: 4),
        Text(missionary.headline, textAlign: TextAlign.center, style: GoogleFonts.inter(color: AppTheme.textSecondaryClaro, fontSize: 13, height: 1.4)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(color: AppTheme.accentYellowLight, borderRadius: BorderRadius.circular(20)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.location_on_rounded, size: 13, color: AppTheme.accentYellowDark),
            const SizedBox(width: 4),
            Text(missionary.location, style: GoogleFonts.inter(color: AppTheme.accentYellowDark, fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        ),
      ]),
    );
  }

  Widget _buildVisibilityToggle(bool isPublic, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(AppTheme.radiusXL), boxShadow: AppTheme.cardShadow),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Perfil Público", style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryClaro)),
          const SizedBox(height: 3),
          Text(isPublic ? "Visível para todos" : "Somente colaboradores", style: GoogleFonts.inter(color: AppTheme.textSecondaryClaro, fontSize: 13)),
        ])),
        Switch(value: isPublic, onChanged: (value) => ref.read(profileVisibilityProvider.notifier).state = value),
      ]),
    );
  }

  Widget _buildStripeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(color: AppTheme.surfaceDark, borderRadius: BorderRadius.circular(AppTheme.radiusXL), boxShadow: AppTheme.darkCardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 44, height: 44, decoration: BoxDecoration(color: const Color(0xFF635BFF).withOpacity(0.15), borderRadius: BorderRadius.circular(AppTheme.radiusSM)),
              child: const Center(child: FaIcon(FontAwesomeIcons.stripe, color: Color(0xFF8B86FF), size: 22))),
          const SizedBox(width: 14),
          Text("Receber Pagamentos", style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
        ]),
        const SizedBox(height: 12),
        Text("Configure sua conta Stripe para receber doações globais de forma segura.", style: GoogleFonts.inter(color: AppTheme.textSecondaryEscuro, fontSize: 13, height: 1.5)),
        const SizedBox(height: 20),
        SizedBox(width: double.infinity, height: 48,
            child: ElevatedButton(
                onPressed: () => context.push('/missionary/stripe-tutorial'),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentYellow, foregroundColor: AppTheme.textPrimaryClaro, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMD))),
                child: Text("Ver Tutorial de Configuração", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13)))),
      ]),
    );
  }

  Widget _buildInfoSection(String title, List<_InfoItem> items) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(AppTheme.radiusXL), boxShadow: AppTheme.cardShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryClaro)),
        const SizedBox(height: 16),
        ...List.generate(items.length, (i) {
          final item = items[i];
          return Column(children: [
            Row(children: [
              Container(width: 38, height: 38, decoration: BoxDecoration(color: AppTheme.accentYellowLight, borderRadius: BorderRadius.circular(AppTheme.radiusXS)),
                  child: Icon(item.icon, size: 17, color: AppTheme.accentYellowDark)),
              const SizedBox(width: 14),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(item.label, style: GoogleFonts.inter(color: AppTheme.textTertiaryClaro, fontSize: 11, fontWeight: FontWeight.w500)),
                Text(item.value, style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 14, color: AppTheme.textPrimaryClaro)),
              ])),
            ]),
            if (i < items.length - 1) const Padding(padding: EdgeInsets.symmetric(vertical: 10), child: Divider(height: 1)),
          ]);
        }),
      ]),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  _InfoItem(this.icon, this.label, this.value);
}
