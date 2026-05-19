import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/services/joshua_project_service.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ImpactMapWidget extends ConsumerStatefulWidget {
  const ImpactMapWidget({super.key});

  @override
  ConsumerState<ImpactMapWidget> createState() => _ImpactMapWidgetState();
}

class _ImpactMapWidgetState extends ConsumerState<ImpactMapWidget> {
  final MapController _mapController = MapController();
  List<JoshuaCountry> _countries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final service = ref.read(joshuaProjectServiceProvider);
    final countries = await service.getCountries();
    if (mounted) {
      setState(() {
        _countries = countries;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.accentYellow));
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: const LatLng(0, 0),
            initialZoom: 2.5,
            minZoom: 2,
            maxZoom: 10,
          ),
          children: [
            // Dark HUD Tiles (CartoDB Dark Matter)
            TileLayer(
              urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
              subdomains: const ['a', 'b', 'c', 'd'],
            ),
            
            // Pulse Markers Layer
            MarkerLayer(
              markers: _countries.map((country) {
                // Approximate coordinates for countries (as JoshuaProjectService doesn't have them in the fallback)
                // In a real app, we'd have a coordinate mapping or use people groups
                final coords = _getCountryCoords(country.rog3);
                return Marker(
                  point: coords,
                  width: 60,
                  height: 60,
                  child: _PulseMarker(country: country),
                );
              }).toList(),
            ),
          ],
        ),
        
        // HUD Overlay Elements
        Positioned(
          top: 20,
          left: 20,
          child: _buildHUDPanel("IMPACTO GLOBAL", "DADOS EM TEMPO REAL (Joshua Project)"),
        ),
        
        Positioned(
          bottom: 30,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildHUDLegend("Necessidade Alta", AppTheme.accentYellow),
              _buildHUDLegend("Missão Ativa", AppTheme.primaryGreen),
            ],
          ),
        ),
      ],
    );
  }

  LatLng _getCountryCoords(String rog3) {
    final Map<String, LatLng> coordsMapping = {
      'BRA': const LatLng(-14.235, -51.925),
      'JPN': const LatLng(36.204, 138.252),
      'IND': const LatLng(20.593, 78.962),
      'CHN': const LatLng(35.861, 104.195),
      'MOZ': const LatLng(-18.665, 35.529),
      'NGA': const LatLng(9.082, 8.675),
      'USA': const LatLng(37.090, -95.712),
      'EGY': const LatLng(26.820, 30.802),
      'RUS': const LatLng(61.524, 105.318),
      'DEU': const LatLng(51.165, 10.451),
      'FRA': const LatLng(46.227, 2.213),
    };
    return coordsMapping[rog3] ?? const LatLng(0, 0);
  }

  Widget _buildHUDPanel(String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentYellow.withOpacity(0.3)),
        boxShadow: [BoxShadow(color: AppTheme.accentYellow.withOpacity(0.1), blurRadius: 10)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.rubik(color: AppTheme.accentYellow, fontWeight: FontWeight.bold, fontSize: 14)),
          Text(subtitle, style: GoogleFonts.inter(color: Colors.white, fontSize: 10, letterSpacing: 0.5)),
        ],
      ),
    );
  }

  Widget _buildHUDLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: GoogleFonts.inter(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
        const SizedBox(width: 8),
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color, blurRadius: 5)]),
        ),
      ],
    );
  }
}

class _PulseMarker extends StatefulWidget {
  final JoshuaCountry country;
  const _PulseMarker({required this.country});

  @override
  State<_PulseMarker> createState() => _PulseMarkerState();
}

class _PulseMarkerState extends State<_PulseMarker> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final needColor = widget.country.percentEvangelical < 5 ? AppTheme.accentYellow : AppTheme.primaryGreen;
    
    return GestureDetector(
      onTap: () => _showCountryInfo(context),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 30 * _controller.value,
                  height: 30 * _controller.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: needColor.withOpacity(1 - _controller.value),
                  ),
                ),
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: needColor,
                    boxShadow: [BoxShadow(color: needColor, blurRadius: 8)],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCountryInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.network(widget.country.flagUrl, width: 40),
                const SizedBox(width: 16),
                Text(widget.country.name, style: GoogleFonts.lora(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow("Evangélicos:", "${widget.country.percentEvangelical}%"),
            _buildInfoRow("População:", "${(widget.country.population / 1000000).toStringAsFixed(1)}M"),
            _buildInfoRow("Religião Predominante:", widget.country.primaryReligion),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentYellow, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text("VER MISSIONÁRIOS", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 13)),
          Text(value, style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
