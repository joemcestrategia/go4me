import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go4me/core/services/joshua_project_service.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/features/landing/missionary_page.dart';
import 'package:go4me/core/data/mock_repository.dart';
import 'package:go4me/core/models/missionary.dart';
import 'package:go4me/features/home/region_profile_page.dart';
import 'package:go4me/features/search/country_card_detail_page.dart';

// Provider to fetch People Groups for a specific country
final countryPeopleGroupsProvider =
    FutureProvider.family<List<JoshuaPeopleGroup>, String>((ref, rog3) async {
      final service = ref.watch(joshuaProjectServiceProvider);
      return service.getPeopleGroupsByCountry(rog3);
    });

// Provider to fetch Missionaries for a specific country (Mock)
final countryMissionariesProvider =
    FutureProvider.family<List<MissionaryData>, String>((
      ref,
      countryCode,
    ) async {
      await Future.delayed(const Duration(milliseconds: 300));
      return MockRepository.allMissionaries
          .where(
            (m) =>
                m.isPublic &&
                (m.countryCode.toLowerCase() == countryCode.toLowerCase() ||
                    m.location.toLowerCase().contains(
                      countryCode.toLowerCase(),
                    )),
          )
          .toList();
    });

class CountryDetailsPage extends ConsumerStatefulWidget {
  final JoshuaCountry country;

  const CountryDetailsPage({super.key, required this.country});

  @override
  ConsumerState<CountryDetailsPage> createState() => _CountryDetailsPageState();
}

class _CountryDetailsPageState extends ConsumerState<CountryDetailsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final peopleGroupsAsync = ref.watch(
      countryPeopleGroupsProvider(widget.country.rog3),
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(widget.country.name),
        backgroundColor: AppTheme.primaryGreen,
        actions: [
          if (widget.country.window1040.isNotEmpty)
            _buildWindow1040Button(context),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentGreen,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "GRUPOS ÉTNICOS"),
            Tab(text: "MISSIONÁRIOS"),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildDashboardHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPeopleGroupsList(peopleGroupsAsync),
                _buildMissionariesList(ref),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 10/40 Window help button
  Widget _buildWindow1040Button(BuildContext context) {
    final isIn1040 = widget.country.window1040 == 'Y';
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: IconButton(
        icon: Stack(
          clipBehavior: Clip.none,
          children: [
            const Icon(Icons.help_outline, size: 24),
            if (isIn1040)
              Positioned(
                right: -2,
                top: -2,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        tooltip: 'Janela 10/40',
        onPressed: () => _showWindow1040Dialog(context),
      ),
    );
  }

  void _showWindow1040Dialog(BuildContext context) {
    final c = widget.country;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.public, color: Colors.red, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Janela 10/40',
                style: GoogleFonts.rubik(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'A "Janela 10/40" é uma região do mundo localizada entre os paralelos '
              '10° e 40° norte do equador, abrangendo o norte da África, o Oriente '
              'Médio e grande parte da Ásia.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Essa região concentra:',
              style: GoogleFonts.rubik(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            _bulletPoint('A maioria dos povos não alcançados do mundo'),
            _bulletPoint('Os menores percentuais de cristãos'),
            _bulletPoint('Os maiores níveis de pobreza e perseguição'),
            _bulletPoint('As maiores restrições ao evangelho'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (c.window1040 == 'Y' ? Colors.red : Colors.green)
                    .withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: (c.window1040 == 'Y' ? Colors.red : Colors.green)
                      .withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    c.window1040 == 'Y'
                        ? Icons.warning_amber_rounded
                        : Icons.check_circle,
                    color: c.window1040 == 'Y' ? Colors.red : Colors.green,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${c.name} ${c.window1040 == "Y" ? "está" : "não está"} na Janela 10/40.',
                      style: GoogleFonts.rubik(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: c.window1040 == 'Y' ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Entendi',
              style: TextStyle(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              color: Colors.red[300],
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[700],
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Format numbers helper
  String _fmt(int n) {
    if (n >= 1000000000) return "${(n / 1000000000).toStringAsFixed(2)}B";
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M";
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(1)}K";
    return "$n";
  }

  void _navigateToDetail(CardDetailType type) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            CountryCardDetailPage(country: widget.country, type: type),
      ),
    );
  }

  Widget _buildDashboardHeader() {
    final c = widget.country;

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Top Row: Flag + Name + Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Flag
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    c.flagUrl,
                    width: 54,
                    height: 38,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.flag, size: 38),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name + Region
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.rubik(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 13,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            c.region,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (c.capital.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.apartment,
                            size: 13,
                            color: Colors.grey[500],
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              c.capital,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // % Evangelical Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: _getColor(c.percentEvangelical).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _getColor(c.percentEvangelical).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.pie_chart,
                      size: 13,
                      color: _getColor(c.percentEvangelical),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "${c.percentEvangelical.toStringAsFixed(1)}%",
                      style: TextStyle(
                        color: _getColor(c.percentEvangelical),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Dashboard Cards Grid — Navigate to detail pages
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Grupos Étnicos",
                  _fmt(c.numPeopleGroups),
                  Icons.groups,
                  Colors.blue,
                  onTap: () => _navigateToDetail(CardDetailType.groups),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  "Não Alcançados",
                  _fmt(c.numUnreachedPeopleGroups),
                  Icons.warning_amber_rounded,
                  Colors.orange,
                  onTap: () => _navigateToDetail(CardDetailType.unreached),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "População",
                  _fmt(c.population),
                  Icons.public,
                  Colors.blueGrey,
                  onTap: () => _navigateToDetail(CardDetailType.population),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  "Pop. Não Alcançada",
                  _fmt(c.populationUnreached),
                  Icons.person_off,
                  Colors.red,
                  onTap: () => _navigateToDetail(CardDetailType.unreachedPop),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.12)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.rubik(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color.withValues(alpha: 0.9),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 2),
                    Icon(
                      Icons.chevron_right,
                      size: 14,
                      color: Colors.grey[400],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeopleGroupsList(
    AsyncValue<List<JoshuaPeopleGroup>> groupsAsync,
  ) {
    return groupsAsync.when(
      data: (groups) {
        if (groups.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.groups_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  "Nenhum grupo encontrado.",
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  "Verifique sua conexão ou tente novamente.",
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          );
        }
        final sortedGroups = List<JoshuaPeopleGroup>.from(groups)
          ..sort((a, b) => a.percentChristian.compareTo(b.percentChristian));

        return ListView.separated(
          itemCount: sortedGroups.length,
          padding: const EdgeInsets.all(16),
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final group = sortedGroups[index];
            final percent = group.percentChristian;
            final isUnreached = percent <= 2.0;

            return Card(
              elevation: 0,
              color: Colors.white,
              shape: RoundedRectangleBorder(
                side: BorderSide(
                  color: isUnreached
                      ? Colors.orange.withValues(alpha: 0.3)
                      : Colors.grey.shade200,
                  width: isUnreached ? 1.5 : 1.0,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => RegionProfilePage(country: widget.country),
                    ),
                  );
                },
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                title: Text(
                  group.peopNameInCountry,
                  style: GoogleFonts.rubik(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        Icons.language,
                        group.language.isEmpty
                            ? "Idioma desc."
                            : group.language,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.account_balance,
                        group.primaryReligion.isEmpty
                            ? "Religião desc."
                            : group.primaryReligion,
                      ),
                      const SizedBox(height: 4),
                      _buildInfoRow(
                        Icons.groups,
                        "Pop: ${_fmt(group.population)}",
                      ),
                    ],
                  ),
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      "${percent.toStringAsFixed(1)}%",
                      style: GoogleFonts.rubik(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: _getColor(percent),
                      ),
                    ),
                    Text(
                      "Cristãos",
                      style: TextStyle(
                        fontSize: 11,
                        color: _getColor(percent),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Erro: $e")),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildMissionariesList(WidgetRef ref) {
    final missionariesAsync = ref.watch(
      countryMissionariesProvider(widget.country.rog3),
    );

    return missionariesAsync.when(
      data: (missionaries) {
        if (missionaries.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.person_off, size: 48, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  "Nenhum missionário cadastrado em ${widget.country.name}.",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: missionaries.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final m = missionaries[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(m.profileImageUrl),
                ),
                title: Text(
                  m.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text("${m.location} • ${m.headline}"),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MissionaryPage(slug: m.slug),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text("Erro: $e")),
    );
  }

  Color _getColor(double percent) {
    if (percent <= 2.0) return Colors.red;
    if (percent < 10.0) return Colors.orange;
    return Colors.green;
  }
}
