import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/core/providers/data_providers.dart';
import 'package:go4me/core/data/supabase_repository.dart';
import 'package:go4me/core/models/missionary.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _headlineController;
  late TextEditingController _storyController;
  late TextEditingController _locationController;
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _headlineController = TextEditingController();
    _storyController = TextEditingController();
    _locationController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);

    final repository = ref.read(repositoryProvider);
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        final missionary = await repository.getMissionaryById(user.id);
        if (mounted && missionary != null) {
          _nameController.text = missionary.name;
          _headlineController.text = missionary.headline;
          _storyController.text = missionary.fullStory;
          _locationController.text = missionary.location;
        }
      } catch (_) {}
    }

    setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);

    try {
      final repository = ref.read(repositoryProvider);
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final response = await Supabase.instance.client
          .from('missionaries')
          .select('id')
          .eq('profile_id', user.id)
          .maybeSingle();

      if (response == null) return;
      final id = response['id'];

      await repository.updateMissionaryProfile(id, {
        'name': _nameController.text.trim(),
        'headline': _headlineController.text.trim(),
        'full_story': _storyController.text.trim(),
        'location': _locationController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      ref.invalidate(currentMissionaryProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Perfil atualizado com sucesso!',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: AppTheme.successGreen,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar: $e',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }

    setState(() => _isSaving = false);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _headlineController.dispose();
    _storyController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text('Editar Perfil',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.textPrimaryClaro)),
        backgroundColor: AppTheme.background,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveProfile,
            child: _isSaving
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentYellow))
                : Text('Salvar', style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppTheme.accentYellow)),
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: AppTheme.accentYellow))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Center(
                    child: Stack(children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppTheme.accentYellowLight,
                        child: const Icon(Icons.person_rounded, size: 50, color: AppTheme.accentYellowDark),
                      ),
                      Positioned(
                        bottom: 0, right: 0,
                        child: Container(
                          width: 32, height: 32,
                          decoration: const BoxDecoration(color: AppTheme.accentYellow, shape: BoxShape.circle),
                          child: const Icon(Icons.camera_alt_rounded, size: 16, color: AppTheme.textPrimaryClaro),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 36),
                  _buildField('Nome', _nameController, hint: 'Seu nome completo'),
                  const SizedBox(height: 20),
                  _buildField('Headline', _headlineController, hint: 'Uma frase que resuma sua missão'),
                  const SizedBox(height: 20),
                  _buildField('Localização', _locationController, hint: 'Cidade, País'),
                  const SizedBox(height: 20),
                  _buildSectionTitle('Sua História'),
                  const SizedBox(height: 10),
                  Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.cardShadow,
                    ),
                    child: TextField(
                      controller: _storyController,
                      maxLines: 10,
                      style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textPrimaryClaro, height: 1.6),
                      decoration: InputDecoration(
                        hintText: 'Conte sua história... O que te levou à missão? O que você faz no campo?',
                        hintStyle: GoogleFonts.inter(color: AppTheme.textTertiaryClaro, fontSize: 15),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.all(20),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      child: _isSaving
                          ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.textPrimaryClaro))
                          : Text('Salvar Alterações',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 40),
                ]),
              ),
            ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {String? hint}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimaryClaro)),
      const SizedBox(height: 8),
      Container(
        decoration: BoxDecoration(color: AppTheme.surfaceLight, borderRadius: BorderRadius.circular(14), boxShadow: AppTheme.cardShadow),
        child: TextField(
          controller: controller,
          style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textPrimaryClaro),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.inter(color: AppTheme.textTertiaryClaro),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
      ),
    ]);
  }

  Widget _buildSectionTitle(String text) {
    return Text(text, style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryClaro, letterSpacing: -0.2));
  }
}
