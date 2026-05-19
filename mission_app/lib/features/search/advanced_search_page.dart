import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/services/joshua_project_service.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/features/search/country_details_page.dart';
import 'package:go4me/features/search/advanced_search_provider.dart';
import 'package:go4me/features/landing/missionary_page.dart';
import 'package:go4me/core/models/missionary.dart';
import 'package:go4me/features/search/widgets/impact_map_widget.dart';
import 'package:go4me/core/services/locale_service.dart';

class AdvancedSearchPage extends ConsumerStatefulWidget {
  const AdvancedSearchPage({super.key});

  @override
  ConsumerState<AdvancedSearchPage> createState() => _AdvancedSearchPageState();
}

class _AdvancedSearchPageState extends ConsumerState<AdvancedSearchPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(advancedSearchProvider);
    final searchNotifier = ref.read(advancedSearchProvider.notifier);

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Column(
        children: [
          // ── Warm Header with Search ───────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFFFF8D6), AppTheme.background],
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 52, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Explorar Missões",
                      style: GoogleFonts.inter(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimaryClaro,
                        letterSpacing: -0.5,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.tune_rounded,
                          color: AppTheme.textPrimaryClaro),
                      onPressed: () => _showFilterSheet(context),
                      style: IconButton.styleFrom(
                        backgroundColor: AppTheme.surfaceLight,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSM),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _searchController,
                  onChanged: (val) => searchNotifier.setQuery(val),
                  style: GoogleFonts.inter(
                      fontSize: 15, color: AppTheme.textPrimaryClaro),
                  decoration: InputDecoration(
                    hintText: "País, região ou missionário...",
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: AppTheme.textTertiaryClaro, size: 20),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 16),
                    filled: true,
                    fillColor: AppTheme.surfaceLight,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLG),
                      borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLG),
                      borderSide: const BorderSide(
                          color: Color(0xFFE5E7EB)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLG),
                      borderSide: const BorderSide(
                          color: AppTheme.accentYellow, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Tabs
          _buildSearchTabs(searchState, searchNotifier),

          // Category chips (only in missionaries tab)
          if (searchState.tab == SearchTab.missionaries)
            _buildCategoryChips(searchState, searchNotifier),

          // Results
          Expanded(
            child: _buildResultsSection(searchState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchTabs(AdvancedSearchState state, AdvancedSearchNotifier notifier) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          _TabItem(
            label: "PAÍSES",
            isActive: state.tab == SearchTab.countries,
            onTap: () => notifier.setTab(SearchTab.countries),
          ),
          const SizedBox(width: 12),
          _TabItem(
            label: "MISSIONÁRIOS",
            isActive: state.tab == SearchTab.missionaries,
            onTap: () => notifier.setTab(SearchTab.missionaries),
          ),
          const SizedBox(width: 12),
          _TabItem(
            label: "MAPA",
            isActive: state.tab == SearchTab.map,
            onTap: () => notifier.setTab(SearchTab.map),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChips(AdvancedSearchState state, AdvancedSearchNotifier notifier) {
    final strings = ref.watch(appStringsProvider);
    const categories = [
      'church_planting', 'discipleship', 'humanitarian', 'education',
      'health', 'water', 'bible_translation', 'street_outreach', 'orphans', 'urban',
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Row(children: [
        _CategoryChip(
          label: strings.allCategories,
          isActive: state.categoryFilter.isEmpty,
          onTap: () => notifier.setCategory(''),
        ),
        const SizedBox(width: 6),
        ...categories.map((cat) => Padding(
          padding: const EdgeInsets.only(right: 6),
          child: _CategoryChip(
            label: strings.categoryName(cat),
            isActive: state.categoryFilter == cat,
            onTap: () => notifier.setCategory(cat),
          ),
        )),
      ]),
    );
  }

  Widget _buildResultsSection(AdvancedSearchState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.tab == SearchTab.map) {
      return const ImpactMapWidget();
    }

    if (state.tab == SearchTab.countries) {
      if (state.filteredCountries.isEmpty) {
        return _buildEmptyState("Nenhum país encontrado.");
      }
      return ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: state.filteredCountries.length,
        itemBuilder: (context, index) => _buildCountryCard(state.filteredCountries[index]),
      );
    } else {
      if (state.filteredMissionaries.isEmpty) {
        return _buildEmptyState("Nenhum missionário encontrado.");
      }
      return GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: state.filteredMissionaries.length,
        itemBuilder: (context, index) => _buildMissionaryGridCard(state.filteredMissionaries[index]),
      );
    }
  }

  Widget _buildCountryCard(JoshuaCountry country) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => CountryDetailsPage(country: country)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.network(
                  "https://flagcdn.com/w160/${country.iso2code.toLowerCase()}.png",
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => const Icon(Icons.flag_rounded),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    country.name,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    country.region,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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

  Widget _buildMissionaryGridCard(MissionaryData missionary) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MissionaryPage(slug: missionary.slug)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  missionary.profileImageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    missionary.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  Text(
                    missionary.location,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: missionary.progress,
                    backgroundColor: AppTheme.accentYellow.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation(AppTheme.accentYellow),
                    minHeight: 4,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(msg, style: TextStyle(color: Colors.grey[500])),
        ],
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    // Implementação pendente para fase futura
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Filtros avançados em breve...")),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentYellow : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppTheme.accentYellow : const Color(0xFFE5E7EB), width: 1.5),
        ),
        child: Text(label, style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isActive ? AppTheme.textPrimaryClaro : AppTheme.textSecondaryClaro,
        )),
      ),
    );
  }
}

class _TabItem extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _TabItem(
      {required this.label, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.textPrimaryClaro
              : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusXL),
          border: Border.all(
            color: isActive
                ? AppTheme.textPrimaryClaro
                : const Color(0xFFE5E7EB),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: isActive ? Colors.white : AppTheme.textSecondaryClaro,
          ),
        ),
      ),
    );
  }
}
