import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/features/missionary/missionary_dashboard.dart';
import 'package:go4me/features/missionary/missionary_feed_tab.dart';
import 'package:go4me/features/missionary/missionary_profile_tab.dart';
import 'package:go4me/features/search/advanced_search_page.dart';
import 'package:go4me/features/prayer/prayer_wall_page.dart';

class MissionaryMainPage extends ConsumerStatefulWidget {
  const MissionaryMainPage({super.key});

  @override
  ConsumerState<MissionaryMainPage> createState() => _MissionaryMainPageState();
}

class _MissionaryMainPageState extends ConsumerState<MissionaryMainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const MissionaryDashboard(),
    const AdvancedSearchPage(),
    const MissionaryFeedTab(),
    const PrayerWallPage(),
    const MissionaryProfileTab(),
  ];

  static const List<({IconData icon, IconData activeIcon, String label})> _navItems = [
    (icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Início'),
    (icon: Icons.search_rounded, activeIcon: Icons.search_rounded, label: 'Explorar'),
    (icon: Icons.dynamic_feed_outlined, activeIcon: Icons.dynamic_feed_rounded, label: 'Feed'),
    (icon: Icons.volunteer_activism_outlined, activeIcon: Icons.volunteer_activism_rounded, label: 'Oração'),
    (icon: Icons.person_outline_rounded, activeIcon: Icons.person_rounded, label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 800;
    if (isDesktop) {
      return Scaffold(
        body: Row(
          children: [
            _buildNavRail(),
            const VerticalDivider(width: 1, thickness: 1, color: Color(0xFFF3F4F6)),
            Expanded(child: IndexedStack(index: _currentIndex, children: _pages)),
          ],
        ),
      );
    }
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildNavRail() {
    return NavigationRail(
      selectedIndex: _currentIndex,
      onDestinationSelected: (i) => setState(() => _currentIndex = i),
      backgroundColor: AppTheme.surfaceLight,
      labelType: NavigationRailLabelType.all,
      selectedIconTheme: const IconThemeData(color: AppTheme.textPrimaryClaro, size: 22),
      unselectedIconTheme: const IconThemeData(color: AppTheme.textTertiaryClaro, size: 22),
      selectedLabelTextStyle: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textPrimaryClaro),
      unselectedLabelTextStyle: GoogleFonts.inter(
        fontSize: 11, fontWeight: FontWeight.w400, color: AppTheme.textTertiaryClaro),
      indicatorColor: AppTheme.accentYellow.withOpacity(0.15),
      destinations: _navItems.map((item) => NavigationRailDestination(
        icon: Icon(item.icon),
        selectedIcon: Icon(item.activeIcon),
        label: Text(item.label),
      )).toList(),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        border: const Border(
          top: BorderSide(color: Color(0xFFF3F4F6), width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(_navItems.length, (index) {
              final item = _navItems[index];
              final isActive = _currentIndex == index;
              return GestureDetector(
                onTap: () => setState(() => _currentIndex = index),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppTheme.accentYellow.withOpacity(0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isActive ? item.activeIcon : item.icon,
                        size: 24,
                        color: isActive
                            ? AppTheme.textPrimaryClaro
                            : AppTheme.textTertiaryClaro,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.w400,
                          color: isActive
                              ? AppTheme.textPrimaryClaro
                              : AppTheme.textTertiaryClaro,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
