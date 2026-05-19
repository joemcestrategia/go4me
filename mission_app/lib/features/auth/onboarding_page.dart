import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go4me/features/auth/controllers/auth_controller.dart';
import 'package:go4me/core/services/auth_repository.dart';
import 'package:go4me/core/services/supabase_service.dart';
import 'package:go4me/core/models/user_profile.dart' as model;
import 'package:supabase_flutter/supabase_flutter.dart';

enum OnboardingRole { missionary, sower }

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  OnboardingRole? _selectedRole;
  bool _obscurePassword = true;
  bool _isCheckingSlug = false;
  bool _slugAvailable = false;
  bool _slugChecked = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _countryController = TextEditingController();
  final _slugController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _slugController.addListener(_onSlugChanged);
  }

  void _onSlugChanged() {
    if (_slugChecked) {
      setState(() {
        _slugChecked = false;
        _slugAvailable = false;
      });
    }
  }

  Future<void> _checkSlugAvailability() async {
    final slug = _slugController.text.trim();
    if (slug.length < 3) {
      _showSnackBar('O link deve ter pelo menos 3 caracteres.', isError: true);
      return;
    }

    setState(() => _isCheckingSlug = true);

    try {
      final response = await SupabaseService.client
          .from('profiles')
          .select('slug')
          .eq('slug', slug)
          .maybeSingle();

      setState(() {
        _slugAvailable = response == null;
        _slugChecked = true;
        _isCheckingSlug = false;
      });

      if (!_slugAvailable && mounted) {
        _showSnackBar('Este link já está em uso. Escolha outro.', isError: true);
      }
    } catch (e) {
      setState(() => _isCheckingSlug = false);
      if (mounted) {
        _showSnackBar('Erro ao verificar disponibilidade.', isError: true);
      }
    }
  }

  @override
  void dispose() {
    _slugController.removeListener(_onSlugChanged);
    _pageController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _countryController.dispose();
    _slugController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (_selectedRole == null) return;
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else if (_currentStep == 1) {
      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        _showSnackBar('Preencha todos os campos obrigatórios.', isError: true);
        return;
      }
      if (password.length < 6) {
        _showSnackBar('A senha deve ter pelo menos 6 caracteres.', isError: true);
        return;
      }
      _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
    } else {
      _handleSignUp();
    }
  }

  Future<void> _handleSignUp() async {
    final role = _selectedRole == OnboardingRole.missionary
        ? model.UserRole.missionary
        : model.UserRole.donor;

    final country = _countryController.text.trim();
    final slug = _slugController.text.trim();

    if (_selectedRole == OnboardingRole.missionary && slug.isNotEmpty && !_slugAvailable) {
      _showSnackBar('Verifique a disponibilidade do seu link antes de continuar.', isError: true);
      return;
    }

    await ref.read(authControllerProvider.notifier).signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
          fullName: _nameController.text.trim(),
          role: role,
          country: country.isEmpty ? null : country,
          slug: _selectedRole == OnboardingRole.missionary && slug.isNotEmpty ? slug : null,
        );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (previous?.isLoading == true && next is AsyncData) {
        final user = ref.read(authRepositoryProvider).currentUser;
        if (user != null) {
          final dest = _selectedRole == OnboardingRole.missionary ? '/missionary' : '/donor';
          context.go(dest);
        } else {
          _showSnackBar('Cadastro realizado! Verifique seu e-mail para confirmar sua conta.');
        }
      } else if (next is AsyncError) {
        _showSnackBar(_friendlyError(next.error), isError: true);
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                _buildProgressBar(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (idx) => setState(() => _currentStep = idx),
                    children: [
                      _buildStep1(),
                      _buildStep2(authState),
                      _buildStep3(authState),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Passo ${_currentStep + 1} de 3',
            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondaryClaro, letterSpacing: 0.3),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(3, (index) {
              final isActive = index <= _currentStep;
              return Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  height: 5,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isActive ? AppTheme.accentYellow : const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  String _friendlyError(Object error) {
    if (error is AuthApiException) {
      switch (error.code) {
        case 'user_already_exists':
        case 'email_exists':
          return 'Este e-mail já está cadastrado.';
        case 'weak_password':
          return 'Senha muito fraca. Use pelo menos 6 caracteres.';
        case 'invalid_email':
          return 'E-mail inválido.';
        case 'email_not_confirmed':
          return 'Cadastro realizado! Confirme seu e-mail para entrar.';
        default:
          return error.message;
      }
    }
    final msg = error.toString().toLowerCase();
    if (msg.contains('already registered') || msg.contains('already exists')) {
      return 'Este e-mail já está cadastrado.';
    }
    if (msg.contains('database error') || msg.contains('saving new user')) {
      return 'Erro ao salvar perfil. Verifique as configurações do banco.';
    }
    return error.toString();
  }

  // ETAPA 1: QUEM É VOCÊ?
  Widget _buildStep1() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text("Quem é você?",
              style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimaryClaro, letterSpacing: -0.5))
              .animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 6),
          Text("Escolha seu papel na missão do Go4Me.",
              style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecondaryClaro, height: 1.5))
              .animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 32),
          _buildRoleCard(role: OnboardingRole.missionary, title: "Sou Missionário",
              subtitle: "Quero captar recursos e compartilhar minha jornada.", icon: FontAwesomeIcons.globe, isDark: false)
              .animate().fadeIn(delay: 300.ms).slideX(begin: -0.05),
          const SizedBox(height: 16),
          _buildRoleCard(role: OnboardingRole.sower, title: "Sou Semeador",
              subtitle: "Quero apoiar missões e transformar vidas.", icon: FontAwesomeIcons.seedling, isDark: true)
              .animate().fadeIn(delay: 400.ms).slideX(begin: -0.05),
          const Spacer(),
          SizedBox(width: double.infinity, height: 54,
              child: ElevatedButton(
                  onPressed: _selectedRole != null ? _nextStep : null,
                  child: Text("Continuar", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)))),
          const SizedBox(height: 16),
          Center(
            child: GestureDetector(
              onTap: () => context.push('/login'),
              child: RichText(
                text: TextSpan(
                  text: "Já tem uma conta? ",
                  style: GoogleFonts.inter(color: AppTheme.textSecondaryClaro, fontSize: 14),
                  children: [
                    TextSpan(text: "Entrar",
                        style: GoogleFonts.inter(color: AppTheme.textPrimaryClaro, fontWeight: FontWeight.w700, fontSize: 14, decoration: TextDecoration.underline)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 28),
        ],
      ),
    );
  }

  Widget _buildRoleCard({required OnboardingRole role, required String title, required String subtitle, required IconData icon, required bool isDark}) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          border: Border.all(color: isSelected ? AppTheme.accentYellow : Colors.transparent, width: 2.5),
          boxShadow: isDark ? AppTheme.darkCardShadow : AppTheme.cardShadow,
        ),
        child: Row(
          children: [
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.accentYellow.withOpacity(0.15) : AppTheme.accentYellowLight,
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: Center(child: FaIcon(icon, size: 22, color: isDark ? AppTheme.accentYellow : AppTheme.textPrimaryClaro)),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: GoogleFonts.inter(fontSize: 17, fontWeight: FontWeight.w700, color: isDark ? Colors.white : AppTheme.textPrimaryClaro)),
                const SizedBox(height: 3),
                Text(subtitle, style: GoogleFonts.inter(fontSize: 13, color: isDark ? AppTheme.textSecondaryEscuro : AppTheme.textSecondaryClaro, height: 1.4)),
              ]),
            ),
            const SizedBox(width: 8),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.accentYellow : Colors.transparent,
                border: Border.all(color: isSelected ? AppTheme.accentYellow : (isDark ? Colors.white24 : const Color(0xFFD1D5DB)), width: 2),
              ),
              child: isSelected ? const Icon(Icons.check, size: 13, color: AppTheme.textPrimaryClaro) : null,
            ),
          ],
        ),
      ),
    );
  }

  // ETAPA 2: DADOS BÁSICOS
  Widget _buildStep2(AsyncValue<void> authState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Text("Dados básicos", style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimaryClaro, letterSpacing: -0.5)).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 6),
        Text("Preencha suas informações para criar sua conta.", style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecondaryClaro, height: 1.5)).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 28),
        _buildTextField(label: "Nome Completo", controller: _nameController, hint: "Seu nome completo"),
        const SizedBox(height: 16),
        _buildTextField(label: "E-mail", controller: _emailController, hint: "seu@email.com", keyboardType: TextInputType.emailAddress),
        const SizedBox(height: 16),
        _buildTextField(label: "Senha", controller: _passwordController, hint: "Mínimo 6 caracteres", isPassword: true, obscurePassword: _obscurePassword,
            onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword)),
        const SizedBox(height: 16),
        _buildTextField(label: _selectedRole == OnboardingRole.missionary ? "País onde serve" : "País de origem", controller: _countryController, hint: "Ex: Brasil"),
        const SizedBox(height: 36),
        SizedBox(width: double.infinity, height: 54,
            child: ElevatedButton(
                onPressed: authState.isLoading ? null : _nextStep,
                child: Text("Ir para Perfil", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)))),
        const SizedBox(height: 32),
      ]),
    );
  }

  // ETAPA 3: PERFIL INICIAL
  Widget _buildStep3(AsyncValue<void> authState) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const SizedBox(height: 8),
        Text("Perfil inicial", style: GoogleFonts.inter(fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimaryClaro, letterSpacing: -0.5)).animate().fadeIn(delay: 100.ms),
        const SizedBox(height: 6),
        Text("Adicione uma foto e personalize seu perfil.", style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textSecondaryClaro, height: 1.5)).animate().fadeIn(delay: 200.ms),
        const SizedBox(height: 32),
        Center(
          child: Stack(children: [
            Container(
              width: 100, height: 100,
              decoration: BoxDecoration(
                color: AppTheme.accentYellowLight, shape: BoxShape.circle,
                border: Border.all(color: AppTheme.accentYellow.withOpacity(0.4), width: 2),
              ),
              child: const Icon(Icons.person_rounded, size: 52, color: AppTheme.accentYellowDark),
            ),
            Positioned(
              bottom: 2, right: 2,
              child: Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(color: AppTheme.accentYellow, shape: BoxShape.circle),
                child: const Icon(Icons.camera_alt_rounded, size: 16, color: AppTheme.textPrimaryClaro),
              ),
            ),
          ]),
        ).animate().scale(delay: 200.ms, duration: 400.ms, curve: Curves.elasticOut),
        const SizedBox(height: 36),
        if (_selectedRole == OnboardingRole.missionary) ...[
          _buildTextField(label: "Seu Link Personalizado", controller: _slugController, hint: "seu-nome", prefix: "go4me.org/m/"),
          const SizedBox(height: 8),
          Row(children: [
            if (_isCheckingSlug)
              const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accentYellow))
            else if (_slugChecked && _slugAvailable)
              const Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.successGreen)
            else if (_slugChecked && !_slugAvailable)
              const Icon(Icons.cancel_rounded, size: 14, color: AppTheme.errorRed)
            else
              const SizedBox(width: 14),
            const SizedBox(width: 6),
            Text(
              _isCheckingSlug ? 'Verificando...' : (_slugChecked ? (_slugAvailable ? 'Disponível' : 'Indisponível') : 'Verifique a disponibilidade'),
              style: GoogleFonts.inter(
                color: _isCheckingSlug ? AppTheme.textSecondaryClaro : (_slugChecked ? (_slugAvailable ? AppTheme.successGreen : AppTheme.errorRed) : AppTheme.textTertiaryClaro),
                fontSize: 12, fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: _isCheckingSlug ? null : _checkSlugAvailability,
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.accentYellow,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text("Verificar", style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ]),
          const SizedBox(height: 24),
        ],
        const SizedBox(height: 12),
        SizedBox(width: double.infinity, height: 54,
            child: ElevatedButton(
                onPressed: authState.isLoading ? null : _handleSignUp,
                child: authState.isLoading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.textPrimaryClaro))
                    : Text("Concluir Cadastro", style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)))),
        const SizedBox(height: 24),
        Center(
          child: TextButton(
            onPressed: authState.isLoading ? null : () async {
              final email = _emailController.text.trim();
              if (email.isEmpty) return;
              await ref.read(authControllerProvider.notifier).resendConfirmation(email);
              if (mounted) _showSnackBar('E-mail reenviado com sucesso! Verifique sua caixa de entrada.');
            },
            child: Text("Não recebeu o e-mail? Reenviar",
                style: GoogleFonts.inter(color: AppTheme.textSecondaryClaro, fontWeight: FontWeight.w600, fontSize: 14, decoration: TextDecoration.underline)),
          ),
        ),
        const SizedBox(height: 32),
      ]),
    );
  }

  Widget _buildTextField({required String label, required TextEditingController controller, String? hint, String? prefix, bool isPassword = false, bool obscurePassword = true, VoidCallback? onToggleObscure, TextInputType? keyboardType}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 13, color: AppTheme.textPrimaryClaro)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        obscureText: isPassword && obscurePassword,
        keyboardType: keyboardType,
        style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textPrimaryClaro),
        decoration: InputDecoration(
          hintText: hint,
          prefixText: prefix,
          prefixStyle: GoogleFonts.inter(color: AppTheme.textSecondaryClaro, fontSize: 15),
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppTheme.textSecondaryClaro),
                  onPressed: onToggleObscure,
                )
              : null,
        ),
      ),
    ]);
  }
}
