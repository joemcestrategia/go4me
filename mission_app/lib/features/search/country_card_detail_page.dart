import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/services/joshua_project_service.dart';
import 'package:go4me/core/theme/app_theme.dart';

/// Enum to define which card detail to show
enum CardDetailType { groups, unreached, population, unreachedPop }

class CountryCardDetailPage extends StatelessWidget {
  final JoshuaCountry country;
  final CardDetailType type;

  const CountryCardDetailPage({
    super.key,
    required this.country,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: _headerColor,
        title: Text(
          _title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          if (country.window1040.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.help_outline),
              tooltip: 'Janela 10/40',
              onPressed: () => _showWindow1040Info(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Country header card
            _buildCountryHeader(),
            const SizedBox(height: 24),
            // Main content based on type
            ..._buildContent(context),
          ],
        ),
      ),
    );
  }

  // --- Header ---
  Widget _buildCountryHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                country.flagUrl,
                width: 56,
                height: 40,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.flag, size: 40),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  country.name,
                  style: GoogleFonts.rubik(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  country.region,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
                if (country.capital.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    country.capital,
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          // 10/40 badge
          if (country.window1040 == 'Y')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
              ),
              child: Text(
                '10/40',
                style: GoogleFonts.rubik(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- Content builders ---
  List<Widget> _buildContent(BuildContext context) {
    switch (type) {
      case CardDetailType.groups:
        return _buildGroupsContent();
      case CardDetailType.unreached:
        return _buildUnreachedContent();
      case CardDetailType.population:
        return _buildPopulationContent();
      case CardDetailType.unreachedPop:
        return _buildUnreachedPopContent();
    }
  }

  // GROUPS PAGE
  List<Widget> _buildGroupsContent() {
    return [
      _sectionTitle('Resumo de Grupos Étnicos', Icons.groups),
      const SizedBox(height: 12),
      _statsGrid([
        _StatData(
          'Total de Grupos',
          '${country.numPeopleGroups}',
          Icons.groups,
          Colors.blue,
        ),
        _StatData(
          'Não Alcançados',
          '${country.numUnreachedPeopleGroups}',
          Icons.warning_amber_rounded,
          Colors.orange,
        ),
        _StatData(
          'Povos de Fronteira',
          '${country.numFrontierPeopleGroups}',
          Icons.shield,
          Colors.red,
        ),
        _StatData(
          'Idioma Oficial',
          country.officialLang.isNotEmpty ? country.officialLang : '—',
          Icons.language,
          Colors.teal,
        ),
      ]),
      const SizedBox(height: 28),
      _sectionTitle('Religiões no País', Icons.account_balance),
      const SizedBox(height: 12),
      _buildReligionBreakdown(),
      const SizedBox(height: 28),
      _sectionTitle('Informações Adicionais', Icons.info_outline),
      const SizedBox(height: 12),
      _infoCard([
        _InfoRow(
          'Escala JP',
          country.jpScaleText.isNotEmpty ? country.jpScaleText : '—',
        ),
        _InfoRow('Janela 10/40', country.window1040 == 'Y' ? 'Sim ⚠️' : 'Não'),
        _InfoRow(
          'Religião Principal',
          country.primaryReligion.isNotEmpty ? country.primaryReligion : '—',
        ),
      ]),
    ];
  }

  // UNREACHED PAGE
  List<Widget> _buildUnreachedContent() {
    final percentUnreachedGroups = country.numPeopleGroups > 0
        ? (country.numUnreachedPeopleGroups / country.numPeopleGroups * 100)
        : 0.0;

    return [
      _sectionTitle('Grupos Não Alcançados', Icons.warning_amber_rounded),
      const SizedBox(height: 12),
      _statsGrid([
        _StatData(
          'Não Alcançados',
          '${country.numUnreachedPeopleGroups}',
          Icons.warning_amber_rounded,
          Colors.orange,
        ),
        _StatData(
          '% dos Grupos',
          '${percentUnreachedGroups.toStringAsFixed(1)}%',
          Icons.pie_chart,
          Colors.deepOrange,
        ),
        _StatData(
          'Pop. Não Alcançada',
          _fmt(country.populationUnreached),
          Icons.person_off,
          Colors.red,
        ),
        _StatData(
          'Povos de Fronteira',
          '${country.numFrontierPeopleGroups}',
          Icons.shield,
          Colors.red.shade700,
        ),
      ]),
      const SizedBox(height: 24),
      // Progress bar
      _buildProgressCard(
        'Proporção Não Alcançada',
        country.numUnreachedPeopleGroups,
        country.numPeopleGroups,
        Colors.orange,
        '${country.numUnreachedPeopleGroups} de ${country.numPeopleGroups} grupos',
      ),
      const SizedBox(height: 28),
      _sectionTitle('Religiões no País', Icons.account_balance),
      const SizedBox(height: 12),
      _buildReligionBreakdown(),
      const SizedBox(height: 28),
      _sectionTitle('Informações Adicionais', Icons.info_outline),
      const SizedBox(height: 12),
      _infoCard([
        _InfoRow(
          'Escala JP',
          country.jpScaleText.isNotEmpty ? country.jpScaleText : '—',
        ),
        _InfoRow('Janela 10/40', country.window1040 == 'Y' ? 'Sim ⚠️' : 'Não'),
      ]),
    ];
  }

  // POPULATION PAGE
  List<Widget> _buildPopulationContent() {
    return [
      _sectionTitle('Demografia', Icons.public),
      const SizedBox(height: 12),
      _statsGrid([
        _StatData(
          'População Total',
          _fmt(country.population),
          Icons.people,
          Colors.blueGrey,
        ),
        _StatData(
          'Capital',
          country.capital.isNotEmpty ? country.capital : '—',
          Icons.apartment,
          Colors.indigo,
        ),
        _StatData(
          'Pop. Não Alcançada',
          _fmt(country.populationUnreached),
          Icons.person_off,
          Colors.red,
        ),
        _StatData(
          'Idioma Oficial',
          country.officialLang.isNotEmpty ? country.officialLang : '—',
          Icons.language,
          Colors.teal,
        ),
      ]),
      const SizedBox(height: 28),
      _sectionTitle('Religiões no País', Icons.account_balance),
      const SizedBox(height: 12),
      _buildReligionBreakdown(),
      const SizedBox(height: 28),
      _sectionTitle('Grupos Étnicos', Icons.groups),
      const SizedBox(height: 12),
      _infoCard([
        _InfoRow('Total de Grupos', '${country.numPeopleGroups}'),
        _InfoRow('Não Alcançados', '${country.numUnreachedPeopleGroups}'),
        _InfoRow('Povos de Fronteira', '${country.numFrontierPeopleGroups}'),
        _InfoRow(
          'Escala JP',
          country.jpScaleText.isNotEmpty ? country.jpScaleText : '—',
        ),
      ]),
    ];
  }

  // UNREACHED POP PAGE
  List<Widget> _buildUnreachedPopContent() {
    final percentUnreached = country.population > 0
        ? (country.populationUnreached / country.population * 100)
        : 0.0;

    return [
      _sectionTitle('População Não Alcançada', Icons.person_off),
      const SizedBox(height: 12),
      _statsGrid([
        _StatData(
          'Pop. Não Alcançada',
          _fmt(country.populationUnreached),
          Icons.person_off,
          Colors.red,
        ),
        _StatData(
          'Pop. Total',
          _fmt(country.population),
          Icons.people,
          Colors.blueGrey,
        ),
        _StatData(
          '% Não Alcançada',
          '${percentUnreached.toStringAsFixed(1)}%',
          Icons.pie_chart,
          Colors.red.shade700,
        ),
        _StatData(
          'Grupos Não Alcançados',
          '${country.numUnreachedPeopleGroups}',
          Icons.warning_amber_rounded,
          Colors.orange,
        ),
      ]),
      const SizedBox(height: 24),
      _buildProgressCard(
        'Proporção Não Alcançada da População',
        country.populationUnreached,
        country.population,
        Colors.red,
        '${_fmt(country.populationUnreached)} de ${_fmt(country.population)} pessoas',
      ),
      const SizedBox(height: 28),
      _sectionTitle('Religiões no País', Icons.account_balance),
      const SizedBox(height: 12),
      _buildReligionBreakdown(),
      const SizedBox(height: 28),
      _sectionTitle('Informações Adicionais', Icons.info_outline),
      const SizedBox(height: 12),
      _infoCard([
        _InfoRow('Janela 10/40', country.window1040 == 'Y' ? 'Sim ⚠️' : 'Não'),
        _InfoRow(
          'Escala JP',
          country.jpScaleText.isNotEmpty ? country.jpScaleText : '—',
        ),
        _InfoRow(
          'Religião Principal',
          country.primaryReligion.isNotEmpty ? country.primaryReligion : '—',
        ),
      ]),
    ];
  }

  // --- RELIGION BREAKDOWN ---
  Widget _buildReligionBreakdown() {
    final religions = <_ReligionEntry>[
      if (country.percentIslam > 0)
        _ReligionEntry(
          'Islamismo',
          country.percentIslam,
          Colors.green.shade700,
          Icons.mosque,
        ),
      if (country.percentChristianity > 0)
        _ReligionEntry(
          'Cristianismo',
          country.percentChristianity,
          Colors.blue.shade700,
          Icons.church,
        ),
      if (country.percentHinduism > 0)
        _ReligionEntry(
          'Hinduísmo',
          country.percentHinduism,
          Colors.orange.shade700,
          Icons.temple_hindu,
        ),
      if (country.percentBuddhism > 0)
        _ReligionEntry(
          'Budismo',
          country.percentBuddhism,
          Colors.amber.shade700,
          Icons.temple_buddhist,
        ),
      if (country.percentEthnicReligions > 0)
        _ReligionEntry(
          'Religiões Étnicas',
          country.percentEthnicReligions,
          Colors.brown,
          Icons.auto_awesome,
        ),
      if (country.percentNonReligious > 0)
        _ReligionEntry(
          'Não Religiosos',
          country.percentNonReligious,
          Colors.grey,
          Icons.block,
        ),
      if (country.percentOtherSmall > 0)
        _ReligionEntry(
          'Outros',
          country.percentOtherSmall,
          Colors.purple.shade300,
          Icons.more_horiz,
        ),
      if (country.percentEvangelical > 0)
        _ReligionEntry(
          'Evangélicos',
          country.percentEvangelical,
          AppTheme.primaryGreen,
          Icons.menu_book,
        ),
    ];

    // Sort by percentage descending
    religions.sort((a, b) => b.percent.compareTo(a.percent));

    if (religions.isEmpty) {
      return _infoCard([_InfoRow('Dados de religião', 'Não disponível')]);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < religions.length; i++) ...[
            _buildReligionRow(religions[i], i == 0),
            if (i < religions.length - 1)
              Divider(
                height: 1,
                indent: 56,
                endIndent: 16,
                color: Colors.grey[100],
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildReligionRow(_ReligionEntry entry, bool isTop) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
            color: entry.color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(entry.icon, color: entry.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.name,
                      style: GoogleFonts.rubik(
                        fontWeight: isTop ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    if (isTop) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: entry.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Principal',
                          style: TextStyle(
                            fontSize: 9,
                            color: entry.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (entry.percent / 100).clamp(0.0, 1.0),
                    backgroundColor: Colors.grey[100],
                    valueColor: AlwaysStoppedAnimation<Color>(entry.color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${entry.percent.toStringAsFixed(1)}%',
            style: GoogleFonts.rubik(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: entry.color,
            ),
          ),
        ],
      ),
    );
  }

  // --- SHARED WIDGETS ---

  Widget _sectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: _headerColor),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.rubik(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _statsGrid(List<_StatData> stats) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 1.8,
      children: stats.map((s) => _buildSmallStatCard(s)).toList(),
    );
  }

  Widget _buildSmallStatCard(_StatData data) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(data.icon, size: 16, color: data.color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  data.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            data.value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.rubik(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: data.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(
    String title,
    int value,
    int total,
    Color color,
    String subtitle,
  ) {
    final progress = total > 0 ? (value / total).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GoogleFonts.rubik(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '$percent%',
                style: GoogleFonts.rubik(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey[100],
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 10,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _infoCard(List<_InfoRow> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    rows[i].label,
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                  ),
                  Flexible(
                    child: Text(
                      rows[i].value,
                      textAlign: TextAlign.end,
                      style: GoogleFonts.rubik(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (i < rows.length - 1)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.grey[100],
              ),
          ],
        ],
      ),
    );
  }

  // --- 10/40 WINDOW INFO DIALOG ---
  void _showWindow1040Info(BuildContext context) {
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
                color: Colors.red.withOpacity(0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.red,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${country.name} ${country.window1040 == "Y" ? "está" : "não está"} na Janela 10/40.',
                      style: GoogleFonts.rubik(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: country.window1040 == "Y"
                            ? Colors.red
                            : Colors.green,
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

  // --- HELPERS ---
  String _fmt(int n) {
    if (n >= 1000000000) return "${(n / 1000000000).toStringAsFixed(2)}B";
    if (n >= 1000000) return "${(n / 1000000).toStringAsFixed(1)}M";
    if (n >= 1000) return "${(n / 1000).toStringAsFixed(1)}K";
    return "$n";
  }

  String get _title {
    switch (type) {
      case CardDetailType.groups:
        return 'Grupos Étnicos';
      case CardDetailType.unreached:
        return 'Não Alcançados';
      case CardDetailType.population:
        return 'População';
      case CardDetailType.unreachedPop:
        return 'Pop. Não Alcançada';
    }
  }

  Color get _headerColor {
    switch (type) {
      case CardDetailType.groups:
        return Colors.blue.shade700;
      case CardDetailType.unreached:
        return Colors.orange.shade700;
      case CardDetailType.population:
        return Colors.blueGrey.shade700;
      case CardDetailType.unreachedPop:
        return Colors.red.shade700;
    }
  }
}

// Helper data classes
class _StatData {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _StatData(this.label, this.value, this.icon, this.color);
}

class _ReligionEntry {
  final String name;
  final double percent;
  final Color color;
  final IconData icon;
  const _ReligionEntry(this.name, this.percent, this.color, this.icon);
}

class _InfoRow {
  final String label;
  final String value;
  const _InfoRow(this.label, this.value);
}
