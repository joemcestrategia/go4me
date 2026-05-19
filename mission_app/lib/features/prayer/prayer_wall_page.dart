import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/core/models/prayer_request.dart';
import 'package:go4me/core/providers/prayer_provider.dart';
import 'package:go4me/core/services/locale_service.dart';

class PrayerWallPage extends ConsumerStatefulWidget {
  const PrayerWallPage({super.key});

  @override
  ConsumerState<PrayerWallPage> createState() => _PrayerWallPageState();
}

class _PrayerWallPageState extends ConsumerState<PrayerWallPage> {
  final _contentController = TextEditingController();
  bool _isPraise = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _submitPrayer() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) return;

    setState(() => _isSubmitting = true);
    try {
      await ref.read(prayerRepositoryProvider).createPrayerRequest(content, isPraise: _isPraise);
      _contentController.clear();
      setState(() => _isPraise = false);
      ref.invalidate(prayerRequestsProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e', style: GoogleFonts.inter()),
              backgroundColor: AppTheme.errorRed,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
        );
      }
    }
    setState(() => _isSubmitting = false);
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(appStringsProvider);
    final prayersAsync = ref.watch(prayerRequestsProvider);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(strings.prayerWall, style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textPrimaryClaro, fontSize: 18)),
        backgroundColor: AppTheme.background,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Column(children: [
        _buildComposer(strings),
        const Divider(height: 1, color: Color(0xFFE5E7EB)),
        Expanded(
          child: prayersAsync.when(
            data: (prayers) => prayers.isEmpty
                ? Center(
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 72, height: 72, decoration: BoxDecoration(color: AppTheme.accentYellowLight, shape: BoxShape.circle),
                          child: Icon(Icons.volunteer_activism_rounded, size: 34, color: AppTheme.accentYellowDark)),
                      const SizedBox(height: 20),
                      Text(strings.emptyPrayerWall, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryClaro)),
                      const SizedBox(height: 8),
                      Text('Seja o primeiro a compartilhar\num pedido de oração!',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 13, color: AppTheme.textSecondaryClaro, height: 1.5)),
                    ]),
                  )
                : RefreshIndicator(
                    color: AppTheme.accentYellow,
                    onRefresh: () async => ref.invalidate(prayerRequestsProvider),
                    child: ListView.builder(
                      padding: const EdgeInsets.only(top: 4, bottom: 100),
                      itemCount: prayers.length,
                      itemBuilder: (_, i) => _PrayerCard(prayer: prayers[i]),
                    ),
                  ),
            loading: () => Center(child: CircularProgressIndicator(color: AppTheme.accentYellow, strokeWidth: 2.5)),
            error: (err, _) => Center(child: Text('Erro: $err', style: GoogleFonts.inter(color: AppTheme.textSecondaryClaro))),
          ),
        ),
      ]),
    );
  }

  Widget _buildComposer(AppStrings strings) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppTheme.surfaceLight, boxShadow: [
        BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 4, offset: const Offset(0, 2)),
      ]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: 3,
              style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimaryClaro),
              decoration: InputDecoration(
                hintText: _isPraise ? 'Compartilhe uma gratidão...' : 'Escreva seu pedido de oração...',
                hintStyle: GoogleFonts.inter(color: AppTheme.textTertiaryClaro, fontSize: 14),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Color(0xFFE5E7EB))),
                contentPadding: const EdgeInsets.all(14),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _buildToggleChip(
            label: strings.prayerRequest,
            icon: Icons.volunteer_activism,
            isSelected: !_isPraise,
            onTap: () => setState(() => _isPraise = false),
          ),
          const SizedBox(width: 8),
          _buildToggleChip(
            label: 'Gratidão',
            icon: Icons.favorite,
            isSelected: _isPraise,
            onTap: () => setState(() => _isPraise = true),
          ),
          const Spacer(),
          SizedBox(
            height: 40,
            child: ElevatedButton.icon(
              onPressed: _isSubmitting || _contentController.text.trim().isEmpty ? null : _submitPrayer,
              icon: _isSubmitting
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.send_rounded, size: 16),
              label: Text('Enviar', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentYellow,
                foregroundColor: AppTheme.textPrimaryClaro,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
        ]),
      ]),
    );
  }

  Widget _buildToggleChip({required String label, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentYellowLight : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppTheme.accentYellow : Colors.grey[300]!, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 14, color: isSelected ? AppTheme.accentYellowDark : AppTheme.textTertiaryClaro),
          const SizedBox(width: 6),
          Text(label, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: isSelected ? AppTheme.accentYellowDark : AppTheme.textTertiaryClaro)),
        ]),
      ),
    );
  }
}

class _PrayerCard extends ConsumerWidget {
  final PrayerRequest prayer;
  const _PrayerCard({required this.prayer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF3F4F6)),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(8), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: prayer.authorAvatar != null ? NetworkImage(prayer.authorAvatar!) : null,
            backgroundColor: AppTheme.accentYellowLight,
            child: prayer.authorAvatar == null ? const Icon(Icons.person, size: 18, color: AppTheme.accentYellowDark) : null,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(prayer.authorName ?? 'Anônimo',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.textPrimaryClaro)),
              Text(_timeAgo(prayer.createdAt),
                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textTertiaryClaro)),
            ]),
          ),
          if (prayer.isPraise)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.accentYellowLight, borderRadius: BorderRadius.circular(12)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.favorite, size: 12, color: AppTheme.accentYellowDark),
                const SizedBox(width: 4),
                Text('Gratidão', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.accentYellowDark)),
              ]),
            ),
          if (prayer.isAnswered)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: AppTheme.successGreen.withAlpha(30), borderRadius: BorderRadius.circular(12)),
              child: Text('Respondido', style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.successGreen)),
            ),
        ]),
        const SizedBox(height: 12),
        Text(prayer.content, style: GoogleFonts.inter(fontSize: 14, color: AppTheme.textPrimaryClaro, height: 1.5)),
        const SizedBox(height: 14),
        Row(children: [
          _PrayButton(prayer: prayer),
          const Spacer(),
          Text('${prayer.prayerCount} ${prayer.prayerCount == 1 ? 'pessoa orou' : 'pessoas oraram'}',
              style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textTertiaryClaro)),
        ]),
      ]),
    ).animate().fadeIn().slideY(begin: 0.04);
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m atrás';
    if (diff.inHours < 24) return '${diff.inHours}h atrás';
    if (diff.inDays < 7) return '${diff.inDays}d atrás';
    return '${date.day}/${date.month}';
  }
}

class _PrayButton extends ConsumerWidget {
  final PrayerRequest prayer;
  const _PrayButton({required this.prayer});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);

    return GestureDetector(
      onTap: () async {
        final repo = ref.read(prayerRepositoryProvider);
        await repo.togglePrayer(prayer.id);
        ref.invalidate(prayerRequestsProvider);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: prayer.hasPrayed ? AppTheme.accentYellowLight : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: prayer.hasPrayed ? AppTheme.accentYellow : Colors.grey[300]!, width: 1),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.volunteer_activism_rounded,
              size: 16,
              color: prayer.hasPrayed ? AppTheme.accentYellowDark : AppTheme.textTertiaryClaro),
          const SizedBox(width: 6),
          Text(prayer.hasPrayed ? strings.prayed : strings.pray,
              style: GoogleFonts.inter(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: prayer.hasPrayed ? AppTheme.accentYellowDark : AppTheme.textTertiaryClaro)),
        ]),
      ),
    );
  }
}
