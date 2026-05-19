import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go4me/features/home/widgets/world_map_widget.dart';
import 'package:go4me/shared/widgets/responsive_layout.dart';
import 'package:go4me/shared/widgets/mission_app_logo.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Palette constants (dark hero)
// ─────────────────────────────────────────────────────────────────────────────
const _kHeroDark   = Color(0xFF0F1117);
const _kYellow     = AppTheme.accentYellow;
const _kYellowDark = AppTheme.accentYellowDark;

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: ResponsiveLayout(
        mobile: _buildMobileLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        // ── Map layer ──────────────────────────────────────────────────
        Positioned(
          top: 0, left: 0, right: 0,
          height: size.height * 0.62,
          child: const WorldMapWidget(),
        ),

        // ── Dark gradient on top of map ──────────────────────────────
        Positioned(
          top: 0, left: 0, right: 0,
          height: size.height * 0.62,
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xE8101318),
                  Color(0xCC141820),
                  Color(0xFF101318),
                ],
              ),
            ),
          ),
        ),

        // ── Warm white background below (for auth card) ────────────────
        Positioned(
          bottom: 0, left: 0, right: 0,
          height: size.height * 0.5,
          child: Container(color: AppTheme.background),
        ),

        // ── Full scrollable content ──────────────────────────────────
        SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: _buildHeader(),
              ),

              // Hero content (scrollable)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 36),

                      // Badge + headline + sub
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: _buildHeroContent(),
                      ),

                      const SizedBox(height: 32),

                      // Stats divider bar (dark)
                      _buildStatsDarkBar(),

                      const SizedBox(height: 32),

                      // Auth card (white card rising from bottom)
                      _buildAuthCard(context, isCompact: true),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Stack(
      children: [
        // ── Full dark background ──────────────────────────────────────
        Container(color: _kHeroDark),

        // ── World Map (right half, let it bleed) ──────────────────────
        const Positioned.fill(child: WorldMapWidget()),

        // ── Dark vignette over the map ──────────────────────────────
        Positioned.fill(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [
                  Color(0xFF101318),
                  Color(0xEE101318),
                  Color(0xBB101318),
                  Color(0x88101318),
                ],
                stops: [0.0, 0.35, 0.65, 1.0],
              ),
            ),
          ),
        ),

        // ── Header ───────────────────────────────────────────────────
        Positioned(
          top: 0, left: 0, right: 0,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 64, vertical: 32),
            child: _buildHeader(),
          ),
        ),

        // ── Body grid 55 / 45 ─────────────────────────────────────────
        Positioned.fill(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(64, 96, 64, 40),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 11,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildHeroContent(),
                      const SizedBox(height: 56),
                      _buildStatsRow(),
                    ],
                  ),
                ),
                const SizedBox(width: 56),
                Expanded(
                  flex: 9,
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: _buildAuthCard(context, isCompact: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Go4MeLogo(height: 28, useDark: false),
        const ResponsiveVisibility(
          desktop: true,
          child: Row(
            children: [
              _NavLink("Explorar"),
              SizedBox(width: 32),
              _NavLink("Impacto"),
              SizedBox(width: 32),
              _NavLink("Sobre"),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 500.ms);
  }

  // Hero content (used in both mobile & desktop)
  Widget _buildHeroContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Badge ─────────────────────────────────────────────────────
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _kYellow.withOpacity(0.12),
            border: Border.all(color: _kYellow.withOpacity(0.35)),
            borderRadius: BorderRadius.circular(AppTheme.radiusSM),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6, height: 6,
                decoration: const BoxDecoration(
                  color: _kYellow, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                "O MOVER NÃO PARA",
                style: GoogleFonts.inter(
                  color: _kYellow,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.6,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 500.ms),

        const SizedBox(height: 24),

        // ── Headline (two-tone: white + yellow) ───────────────────────
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w900,
              fontSize: 54,
              height: 1.04,
              letterSpacing: -2.0,
            ),
            children: [
              const TextSpan(
                text: "Conecte-se à\n",
                style: TextStyle(color: Colors.white),
              ),
              TextSpan(
                text: "Missão Global.",
                style: GoogleFonts.inter(
                  color: _kYellow,
                  fontWeight: FontWeight.w900,
                  fontSize: 54,
                  letterSpacing: -2.0,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 120.ms).slideY(
              begin: 0.05,
              duration: 600.ms,
              curve: Curves.easeOut,
            ),

        const SizedBox(height: 20),

        // ── Subtitle ────────────────────────────────────────────────
        Text(
          "A plataforma que une semeadores e missionários\nem tempo real. Acompanhe o impacto da sua semente.",
          style: GoogleFonts.inter(
            color: Colors.white.withOpacity(0.55),
            fontSize: 16,
            height: 1.65,
            fontWeight: FontWeight.w400,
          ),
        ).animate().fadeIn(delay: 250.ms),

        const SizedBox(height: 32),

        // ── Avatar trust strip ───────────────────────────────────────
        _buildTrustStrip().animate().fadeIn(delay: 380.ms),
      ],
    );
  }

  Widget _buildTrustStrip() {
    const colors = [
      Color(0xFF6EE7B7), Color(0xFFFBBF24), Color(0xFF93C5FD),
      Color(0xFFF9A8D4), Color(0xFFA78BFA),
    ];
    return Row(
      children: [
        // Stacked circles
        SizedBox(
          width: 5 * 24.0 - 4 * 8.0, // overlapping
          height: 32,
          child: Stack(
            children: List.generate(5, (i) {
              return Positioned(
                left: i * 16.0,
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colors[i],
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: _kHeroDark, width: 2),
                  ),
                ),
              );
            }),
          ),
        ),
        const SizedBox(width: 14),
        RichText(
          text: TextSpan(
            style: GoogleFonts.inter(
                fontSize: 13, color: Colors.white.withOpacity(0.5)),
            children: [
              const TextSpan(
                text: "1.200+ ",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const TextSpan(text: "missionários ativos"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAuthCard(BuildContext context, {required bool isCompact}) {
    return DefaultTabController(
      length: 2,
      child: Container(
        margin: isCompact
            ? const EdgeInsets.symmetric(horizontal: 20)
            : EdgeInsets.zero,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
              isCompact ? AppTheme.radiusXL : AppTheme.radiusXL),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 48,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: _kYellow.withOpacity(0.06),
              blurRadius: 60,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ── Card header strip ────────────────────────────────────
            Container(
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
              child: Row(
                children: [
                  const Go4MeLogo(height: 22, useDark: true),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: _kYellow.withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusSM),
                    ),
                    child: Text(
                      "SEGURO",
                      style: GoogleFonts.inter(
                        color: _kYellowDark,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Segmented tab switcher ────────────────────────────────
            Container(
              margin: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(AppTheme.radiusMD),
              ),
              child: TabBar(
                labelColor: AppTheme.textPrimaryClaro,
                unselectedLabelColor: AppTheme.textTertiaryClaro,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusSM),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.07),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, fontSize: 13),
                unselectedLabelStyle: GoogleFonts.inter(
                    fontWeight: FontWeight.w500, fontSize: 13),
                tabs: const [
                  Tab(text: "Entrar"),
                  Tab(text: "Cadastrar"),
                ],
              ),
            ),

            // ── Form body ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
              child: SizedBox(
                height: isCompact ? 256 : 288,
                child: TabBarView(
                  children: [
                    _buildLoginForm(context),
                    _buildRegisterForm(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ).animate().fadeIn(delay: 350.ms).slideY(
            begin: 0.04,
            duration: 500.ms,
            curve: Curves.easeOut,
          ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        _field(
          hint: "seu@email.com",
          label: "E-mail",
          icon: Icons.email_outlined,
        ),
        const SizedBox(height: 12),
        _field(
          hint: "••••••••",
          label: "Senha",
          icon: Icons.lock_outline_rounded,
          obscure: true,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                    horizontal: 0, vertical: 4)),
            child: Text(
              "Esqueceu a senha?",
              style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textTertiaryClaro),
            ),
          ),
        ),
        const Spacer(),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.push('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kHeroDark,
              foregroundColor: _kYellow,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusMD),
              ),
              elevation: 0,
            ),
            child: Text("Acessar Plataforma",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w700, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterForm(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        Column(
          children: [
            const Icon(Icons.language_rounded,
                color: _kYellow, size: 36),
            const SizedBox(height: 12),
            Text(
              "Junte-se a mais de 1.200\nmissionários ativos",
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                height: 1.5,
              ),
            ),
          ],
        ),
        const Spacer(),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.push('/onboarding'),
            style: ElevatedButton.styleFrom(
              backgroundColor: _kYellow,
              foregroundColor: _kHeroDark,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusMD),
              ),
              elevation: 0,
            ),
            child: Text("Criar Conta Gratuita",
                style: GoogleFonts.inter(
                    fontWeight: FontWeight.w800, fontSize: 15)),
          ),
        ),
      ],
    );
  }

  // Shared compact text field
  Widget _field({
    required String hint,
    required String label,
    required IconData icon,
    bool obscure = false,
  }) {
    return TextField(
      obscureText: obscure,
      style: GoogleFonts.inter(
          fontSize: 14, color: AppTheme.textPrimaryClaro),
      decoration: InputDecoration(
        hintText: hint,
        labelText: label,
        labelStyle: GoogleFonts.inter(
            fontSize: 13, color: AppTheme.textTertiaryClaro),
        prefixIcon: Icon(icon,
            size: 18, color: AppTheme.textTertiaryClaro),
        filled: true,
        fillColor: const Color(0xFFF9FAFB),
        contentPadding: const EdgeInsets.symmetric(
            horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          borderSide:
              const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          borderSide:
              const BorderSide(color: Color(0xFFE5E7EB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          borderSide:
              const BorderSide(color: _kYellow, width: 1.5),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────────────────
  // Stats bar (dark bg version for desktop / hero)
  // ──────────────────────────────────────────────────────────────────────────
  Widget _buildStatsRow() {
    return Row(
      children: [
        _buildStatItem("17.4K", "Povos Não-Alcançados"),
        _vDivider(),
        _buildStatItem("140+", "Países Ativos"),
        _vDivider(),
        _buildStatItem("5.2M", "Vidas Impactadas"),
      ],
    ).animate().fadeIn(delay: 500.ms);
  }

  // Stats bar (dark bg version for mobile - inline below hero)
  Widget _buildStatsDarkBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1E28),
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border:
            Border.all(color: Colors.white.withOpacity(0.06)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStatItem("17.4K", "Povos"),
          _vDivider(),
          _buildStatItem("140+", "Países"),
          _vDivider(),
          _buildStatItem("5.2M", "Vidas"),
        ],
      ),
    ).animate().fadeIn(delay: 420.ms);
  }

  Widget _buildStatItem(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: Colors.white.withOpacity(0.4),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 32,
        color: Colors.white.withOpacity(0.1),
      );
}

class _NavLink extends StatelessWidget {
  final String label;
  const _NavLink(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.inter(
        fontWeight: FontWeight.w500,
        fontSize: 13,
        color: Colors.white.withOpacity(0.6),
      ),
    );
  }
}

class ResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool desktop;

  const ResponsiveVisibility({
    super.key,
    required this.child,
    this.desktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (desktop && width < 900) return const SizedBox.shrink();
    return child;
  }
}
