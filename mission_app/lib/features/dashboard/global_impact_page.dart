import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // rootBundle
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/services/joshua_project_service.dart';
import 'package:go4me/core/theme/app_theme.dart';

// Provider to fetch Countries
final globalImpactCountriesProvider = FutureProvider<List<JoshuaCountry>>((
  ref,
) async {
  final service = ref.watch(joshuaProjectServiceProvider);
  return service.getCountries();
});

class GlobalImpactPage extends ConsumerStatefulWidget {
  const GlobalImpactPage({super.key});

  @override
  ConsumerState<GlobalImpactPage> createState() => _GlobalImpactPageState();
}

class _GlobalImpactPageState extends ConsumerState<GlobalImpactPage> {
  List<Polygon> _polygons = [];
  bool _loadingMap = true;
  late final MapController _mapController;
  Timer? _rotationTimer;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _loadMapData();
    // Animation removed per user request
    // _startRotation();
  }

  @override
  void dispose() {
    _rotationTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // _startRotation removed

  // Comprehensive evangelical percentage data keyed by ISO_A3
  // Source: Joshua Project / Operation World approximate data
  static const Map<String, double> _evangelicalData = {
    'AFG': 0.0,
    'ALB': 0.5,
    'DZA': 0.3,
    'AGO': 22.0,
    'ARG': 9.0,
    'ARM': 1.0,
    'AUS': 12.0,
    'AUT': 0.5,
    'AZE': 0.1,
    'BHS': 36.0,
    'BHR': 0.3,
    'BGD': 0.3,
    'BRB': 33.0,
    'BLR': 1.5,
    'BEL': 1.0,
    'BLZ': 19.0,
    'BEN': 7.0,
    'BTN': 0.5,
    'BOL': 16.0,
    'BIH': 0.1,
    'BWA': 8.0,
    'BRA': 24.0,
    'BRN': 2.5,
    'BGR': 1.8,
    'BFA': 6.0,
    'BDI': 27.0,
    'KHM': 2.0,
    'CMR': 12.0,
    'CAN': 7.0,
    'CPV': 5.0,
    'CAF': 33.0,
    'TCD': 12.0,
    'CHL': 18.0,
    'CHN': 7.0,
    'COL': 10.0,
    'COM': 0.1,
    'COG': 20.0,
    'COD': 18.0,
    'CRI': 15.0,
    'CIV': 6.0,
    'HRV': 0.3,
    'CUB': 5.0,
    'CYP': 0.5,
    'CZE': 0.5,
    'DNK': 4.0,
    'DJI': 0.1,
    'DOM': 8.0,
    'ECU': 8.0,
    'EGY': 3.0,
    'SLV': 35.0,
    'GNQ': 5.0,
    'ERI': 2.0,
    'EST': 5.0,
    'SWZ': 22.0,
    'ETH': 19.0,
    'FJI': 24.0,
    'FIN': 12.0,
    'FRA': 1.0,
    'GAB': 13.0,
    'GMB': 1.5,
    'GEO': 1.0,
    'DEU': 2.1,
    'GHA': 24.0,
    'GRC': 0.3,
    'GTM': 30.0,
    'GIN': 1.0,
    'GNB': 2.0,
    'GUY': 17.0,
    'HTI': 16.0,
    'HND': 30.0,
    'HUN': 2.0,
    'ISL': 4.0,
    'IND': 2.2,
    'IDN': 5.0,
    'IRN': 1.0,
    'IRQ': 0.3,
    'IRL': 1.5,
    'ISR': 0.5,
    'ITA': 1.1,
    'JAM': 25.0,
    'JPN': 0.5,
    'JOR': 0.3,
    'KAZ': 0.5,
    'KEN': 48.0,
    'KWT': 0.3,
    'KGZ': 0.3,
    'LAO': 2.5,
    'LVA': 6.0,
    'LBN': 0.5,
    'LSO': 11.0,
    'LBR': 12.0,
    'LBY': 0.1,
    'LTU': 1.0,
    'LUX': 0.5,
    'MDG': 10.0,
    'MWI': 26.0,
    'MYS': 3.0,
    'MDV': 0.0,
    'MLI': 0.6,
    'MRT': 0.0,
    'MUS': 3.0,
    'MEX': 8.0,
    'MDA': 3.0,
    'MNG': 2.0,
    'MNE': 0.2,
    'MAR': 0.0,
    'MOZ': 12.0,
    'MMR': 5.0,
    'NAM': 10.0,
    'NPL': 2.5,
    'NLD': 4.0,
    'NZL': 15.0,
    'NIC': 30.0,
    'NER': 0.5,
    'NGA': 30.0,
    'PRK': 0.8,
    'MKD': 0.1,
    'NOR': 7.0,
    'OMN': 0.2,
    'PAK': 0.6,
    'PAN': 15.0,
    'PNG': 22.0,
    'PRY': 7.0,
    'PER': 12.0,
    'PHL': 12.0,
    'POL': 0.3,
    'PRT': 3.0,
    'QAT': 0.3,
    'ROU': 5.0,
    'RUS': 1.2,
    'RWA': 26.0,
    'SAU': 0.4,
    'SEN': 0.1,
    'SRB': 0.2,
    'SLE': 4.0,
    'SGP': 12.0,
    'SVK': 1.5,
    'SVN': 0.2,
    'SLB': 30.0,
    'SOM': 0.0,
    'ZAF': 21.0,
    'KOR': 16.0,
    'SSD': 21.0,
    'ESP': 1.0,
    'LKA': 1.0,
    'SDN': 1.5,
    'SUR': 12.0,
    'SWE': 6.0,
    'CHE': 4.0,
    'SYR': 0.1,
    'TWN': 4.0,
    'TJK': 0.1,
    'TZA': 15.0,
    'THA': 0.6,
    'TLS': 3.0,
    'TGO': 8.0,
    'TTO': 18.0,
    'TUN': 0.0,
    'TUR': 0.0,
    'TKM': 0.1,
    'UGA': 34.0,
    'UKR': 3.0,
    'ARE': 0.3,
    'GBR': 7.8,
    'USA': 25.0,
    'URY': 2.0,
    'UZB': 0.1,
    'VUT': 30.0,
    'VEN': 10.0,
    'VNM': 1.8,
    'YEM': 0.0,
    'ZMB': 25.0,
    'ZWE': 30.0,
  };

  Future<void> _loadMapData() async {
    try {
      final String geoJsonString = await rootBundle.loadString(
        'assets/geo/countries.geojson',
      );
      final Map<String, dynamic> geoJson = json.decode(geoJsonString);

      final List<Polygon> polygons = [];
      final features = geoJson['features'] as List<dynamic>;

      for (var feature in features) {
        // Get country code from GeoJSON feature ID
        final String countryCode = (feature['id'] ?? '').toString();

        // Look up evangelical percentage from static data
        final double? pctEvangelical = _evangelicalData[countryCode];

        Color color;
        if (pctEvangelical == null) {
          color = const Color(0xFF374151); // Dark Grey — no data
        } else if (pctEvangelical >= 10.0) {
          color = const Color(0xFF10B981); // Green — reached
        } else if (pctEvangelical >= 2.0) {
          color = const Color(0xFFF59E0B); // Orange — partial
        } else {
          color = const Color(0xFFEF4444); // Red — unreached
        }

        final geometry = feature['geometry'];
        final type = geometry['type'];
        final coords = geometry['coordinates'] as List<dynamic>;

        if (type == 'Polygon') {
          for (var ring in coords) {
            polygons.add(
              Polygon(
                points: _convertPoints(ring),
                color: color.withValues(alpha: 0.8),
                borderColor: Colors.black.withValues(alpha: 0.3),
                borderStrokeWidth: 0.5,
              ),
            );
          }
        } else if (type == 'MultiPolygon') {
          for (var polygonCoords in coords) {
            for (var ring in polygonCoords) {
              polygons.add(
                Polygon(
                  points: _convertPoints(ring),
                  color: color.withValues(alpha: 0.8),
                  borderColor: Colors.black.withValues(alpha: 0.3),
                  borderStrokeWidth: 0.5,
                ),
              );
            }
          }
        }
      }

      if (mounted) {
        setState(() {
          _polygons = polygons;
          _loadingMap = false;
        });
      }
    } catch (e) {
      print("Error loading map: $e");
      if (mounted) setState(() => _loadingMap = false);
    }
  }

  List<LatLng> _convertPoints(List<dynamic> points) {
    return points.map((p) {
      return LatLng((p[1] as num).toDouble(), (p[0] as num).toDouble());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: _loadingMap
          ? Center(
              child: CircularProgressIndicator(color: AppTheme.primaryGreen),
            )
          : Stack(
              children: [
                Positioned.fill(
                  child: FlutterMap(
                    mapController: _mapController,
                    options: const MapOptions(
                      initialCenter: LatLng(20.0, 0.0),
                      initialZoom: 1.5,
                      backgroundColor: Color(0xFF0F172A),
                      // Enabled interaction for exploration
                      interactionOptions: InteractionOptions(
                        flags: InteractiveFlag.all,
                      ),
                    ),
                    children: [PolygonLayer(polygons: _polygons)],
                  ),
                ),

                // Overlay Gradient for cinematic look
                Positioned.fill(
                  child: IgnorePointer(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.3),
                          ],
                          radius: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                // Floating Back Button
                Positioned(
                  top: 48,
                  left: 16,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).pop(),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black45,
                    ),
                  ),
                ),

                // Title Overlay
                Positioned(
                  top: 56,
                  right: 24,
                  child: Text(
                    "ALCANCE GLOBAL",
                    style: GoogleFonts.rubik(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),

                // Legend
                Positioned(
                  bottom: 48,
                  left: 24,
                  right: 24,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildLegendItem(
                          const Color(0xFFEF4444),
                          "Não Alcançado",
                          "< 2%",
                        ),
                        _buildLegendItem(
                          const Color(0xFFF59E0B),
                          "Parcial",
                          "2% - 10%",
                        ),
                        _buildLegendItem(
                          const Color(0xFF10B981),
                          "Alcançado",
                          "> 10%",
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLegendItem(Color color, String label, String sub) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          sub,
          style: GoogleFonts.inter(color: Colors.white54, fontSize: 10),
        ),
      ],
    );
  }
}
