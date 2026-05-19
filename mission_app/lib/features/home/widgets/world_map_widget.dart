import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go4me/core/theme/app_theme.dart';

class WorldMapWidget extends StatefulWidget {
  const WorldMapWidget({super.key});

  @override
  State<WorldMapWidget> createState() => _WorldMapWidgetState();
}

class _WorldMapWidgetState extends State<WorldMapWidget> with SingleTickerProviderStateMixin {
  List<Polygon> _polygons = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  Future<void> _loadMapData() async {
    try {
      final String response = await rootBundle.loadString('assets/geo/countries.geojson');
      final data = json.decode(response);
      
      final List<Polygon> polygons = [];

      for (var feature in data['features']) {
        final geometry = feature['geometry'];
        if (geometry == null) continue;

        if (geometry['type'] == 'Polygon') {
          polygons.add(_parsePolygon(geometry['coordinates']));
        } else if (geometry['type'] == 'MultiPolygon') {
          for (var coords in geometry['coordinates']) {
            polygons.add(_parsePolygon(coords));
          }
        }
      }

      if (mounted) {
        setState(() {
          _polygons = polygons;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Erro ao carregar mapa: $e");
    }
  }

  Polygon _parsePolygon(List coordinates) {
    // GeoJSON coordinates are usually [longitude, latitude]
    final List<LatLng> points = [];
    for (var ring in coordinates) {
      for (var point in ring) {
        points.add(LatLng(point[1].toDouble(), point[0].toDouble()));
      }
    }
    return Polygon(
      points: points,
      color: AppTheme.hudAccent.withOpacity(0.05),
      borderColor: AppTheme.hudAccent.withOpacity(0.3),
      borderStrokeWidth: 0.5,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.hudAccent));
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(20, 0),
        initialZoom: 2.2,
        maxZoom: 4,
        minZoom: 2,
        backgroundColor: const Color(0xFF0A0C10),
        interactionOptions: const InteractionOptions(
          flags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
        ),
      ),
      children: [
        PolygonLayer(polygons: _polygons),
        // Pins de Impacto (Mock)
        _buildImpactPins(),
      ],
    );
  }

  Widget _buildImpactPins() {
    final List<Marker> markers = [
      const Marker(point: LatLng(-15.78, -47.93), child: ImpactPulsePin()), // Brasil
      const Marker(point: LatLng(1.29, 103.85), child: ImpactPulsePin()),  // Singapura
      const Marker(point: LatLng(9.08, 8.67), child: ImpactPulsePin()),   // Nigéria
      const Marker(point: LatLng(35.68, 139.76), child: ImpactPulsePin()), // Japão
    ];

    return MarkerLayer(markers: markers);
  }
}

class ImpactPulsePin extends StatefulWidget {
  const ImpactPulsePin({super.key});

  @override
  State<ImpactPulsePin> createState() => _ImpactPulsePinState();
}

class _ImpactPulsePinState extends State<ImpactPulsePin> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTheme.hudAccent.withOpacity(1 - _controller.value),
            boxShadow: [
              BoxShadow(
                color: AppTheme.hudAccent.withOpacity(0.5 * (1 - _controller.value)),
                blurRadius: 10 * _controller.value,
                spreadRadius: 5 * _controller.value,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.hudAccent,
              ),
            ),
          ),
        );
      },
    );
  }
}
