import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/features/auth/controllers/auth_controller.dart';
import 'package:go4me/core/services/auth_repository.dart';
import 'package:go4me/core/models/user_profile.dart';
import 'package:go4me/shared/widgets/mission_app_logo.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Por favor, preencha todos os campos.', isError: true);
      return;
    }

    await ref.read(authControllerProvider.notifier).login(email, password);
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter(color: Colors.white)),
        backgroundColor: isError ? AppTheme.errorRed : AppTheme.surfaceDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _navigateAfterLogin() async {
    final user = ref.read(authRepositoryProvider).currentUser;
    if (user == null) return;

    try {
      final profile = await ref.read(authRepositoryProvider).getUserProfile(user.id);
      if (profile != null && mounted) {
        final dest = profile.role == UserRole.missionary ? '/missionary' : '/donor';
        context.go(dest);
        return;
      }
    } catch (_) {}

    final role = user.userMetadata?['role'] as String?;
    final dest = role == 'missionary' ? '/missionary' : '/donor';
    if (mounted) context.go(dest);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final size = MediaQuery.of(context).size;

    ref.listen<AsyncValue<void>>(authControllerProvider, (previous, next) {
      if (previous?.isLoading == true) {
        next.whenOrNull(
          data: (_) => _navigateAfterLogin(),
          error: (error, _) {
            _showSnackBar(_friendlyAuthError(error), isError: true);
          },
        );
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.35,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFFFF8D6), AppTheme.background],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppTheme.accentYellow,
                              borderRadius: BorderRadius.circular(AppTheme.radiusLG),
                            ),
                            child: const Icon(
                              Icons.language_rounded,
                              color: AppTheme.textPrimaryClaro,
                              size: 32,
                            ),
                          ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
                          const SizedBox(height: 20),
                          const Go4MeLogo(height: 34, useDark: true)
                              .animate().fadeIn(delay: 200.ms),
                          const SizedBox(height: 6),
                          Text(
                            'Entre na plataforma',
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: AppTheme.textSecondaryClaro,
                            ),
                          ).animate().fadeIn(delay: 300.ms),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
                          boxShadow: AppTheme.cardShadowMd,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildLabel('E-mail'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textPrimaryClaro),
                              decoration: InputDecoration(
                                hintText: 'seu@email.com',
                                prefixIcon: const Icon(Icons.alternate_email_rounded,
                                    size: 20, color: AppTheme.textTertiaryClaro),
                              ),
                            ).animate().fadeIn(delay: 400.ms),
                            const SizedBox(height: 20),
                            _buildLabel('Senha'),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textPrimaryClaro),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: const Icon(Icons.lock_outline_rounded,
                                    size: 20, color: AppTheme.textTertiaryClaro),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                    color: AppTheme.textSecondaryClaro,
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                            ).animate().fadeIn(delay: 500.ms),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () => context.push('/forgot-password'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppTheme.textSecondaryClaro,
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: Text(
                                  'Esqueceu a senha?',
                                  style: GoogleFonts.inter(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ).animate().fadeIn(delay: 600.ms),
                            const SizedBox(height: 28),
                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: authState.isLoading ? null : _handleLogin,
                                child: authState.isLoading
                                    ? const SizedBox(
                                        height: 22, width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5, color: AppTheme.textPrimaryClaro,
                                        ),
                                      )
                                    : Text('Entrar', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                              ),
                            ).animate().fadeIn(delay: 700.ms),
                          ],
                        ),
                      ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.08),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Não tem uma conta?',
                              style: GoogleFonts.inter(color: AppTheme.textSecondaryClaro, fontSize: 14)),
                          TextButton(
                            onPressed: () => context.push('/onboarding'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.textPrimaryClaro,
                              padding: const EdgeInsets.only(left: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text('Cadastrar',
                                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, decoration: TextDecoration.underline)),
                          ),
                        ],
                      ).animate().fadeIn(delay: 900.ms),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _friendlyAuthError(Object error) {
    if (error is AuthApiException) {
      switch (error.code) {
        case 'invalid_credentials':
          return 'E-mail ou senha incorretos. Verifique e tente novamente.';
        case 'email_not_confirmed':
          return 'Confirme seu e-mail antes de entrar.';
        case 'user_not_found':
          return 'Nenhuma conta encontrada com este e-mail.';
        case 'too_many_requests':
          return 'Muitas tentativas. Aguarde um momento e tente novamente.';
        default:
          return error.message;
      }
    }
    return 'Ocorreu um erro. Tente novamente.';
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: AppTheme.textPrimaryClaro, letterSpacing: 0.1,
      ),
    );
  }
}

// ============================================================================
// FORGOT PASSWORD PAGE
// ============================================================================

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _emailController = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Digite seu e-mail.', style: GoogleFonts.inter(color: Colors.white)),
          backgroundColor: AppTheme.errorRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      return;
    }

    try {
      await ref.read(authRepositoryProvider).resetPassword(email);
      setState(() => _sent = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar e-mail. Tente novamente.',
                style: GoogleFonts.inter(color: Colors.white)),
            backgroundColor: AppTheme.errorRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimaryClaro),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.lock_reset_rounded, size: 56, color: AppTheme.accentYellow),
                  const SizedBox(height: 24),
                  Text(
                    _sent ? 'E-mail enviado!' : 'Esqueceu a senha?',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 24, fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimaryClaro, letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _sent
                        ? 'Enviamos um link de recuperação para seu e-mail. Verifique sua caixa de entrada e spam.'
                        : 'Digite seu e-mail e enviaremos um link para redefinir sua senha.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 14, color: AppTheme.textSecondaryClaro, height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),
                  if (!_sent) ...[
                    _buildLabel('E-mail'),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: GoogleFonts.inter(fontSize: 15, color: AppTheme.textPrimaryClaro),
                      decoration: const InputDecoration(
                        hintText: 'seu@email.com',
                        prefixIcon: Icon(Icons.alternate_email_rounded, size: 20, color: AppTheme.textTertiaryClaro),
                      ),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      height: 54,
                      child: ElevatedButton(
                        onPressed: _handleReset,
                        child: Text('Enviar Link', style: GoogleFonts.inter(fontWeight: FontWeight.w700, fontSize: 16)),
                      ),
                    ),
                  ] else ...[
                    SizedBox(
                      height: 54,
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/login'),
                        icon: const Icon(Icons.arrow_back_rounded, size: 18),
                        label: Text('Voltar ao Login', style: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 15)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textPrimaryClaro,
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusXL)),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13, fontWeight: FontWeight.w600,
        color: AppTheme.textPrimaryClaro, letterSpacing: 0.1,
      ),
    );
  }
}
