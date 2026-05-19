import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/constants.dart';
import '../providers/crisis_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});
  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _controller;
  static const _initialCamera = CameraPosition(target: LatLng(33.6844, 73.0479), zoom: 11);

  @override
  Widget build(BuildContext context) {
    final crisesAsync = ref.watch(activeCrisesProvider);
    final unitsAsync = ref.watch(unitsProvider);
    final reroutesAsync = ref.watch(activeReroutesProvider);

    Set<Marker> markers = {};
    Set<Circle> circles = {};
    Set<Polyline> polylines = {};

    // Build markers from data
    crisesAsync.whenData((crises) {
      for (final c in crises) {
        markers.add(Marker(
          markerId: MarkerId('crisis_${c.crisisId}'),
          position: LatLng(c.affectedLat, c.affectedLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(title: '${c.crisisTypeIcon} ${c.crisisTypeLabel}', snippet: '${c.severity} — ${c.affectedAreaName}'),
        ));
        circles.add(Circle(
          circleId: CircleId('crisis_radius_${c.crisisId}'),
          center: LatLng(c.affectedLat, c.affectedLng),
          radius: c.affectedRadiusKm * 1000,
          fillColor: AppColors.severityCritical.withOpacity(0.12),
          strokeColor: AppColors.severityCritical,
          strokeWidth: 2,
        ));
        // Animate camera to crisis
        _controller?.animateCamera(CameraUpdate.newLatLngZoom(LatLng(c.affectedLat, c.affectedLng), 13));
      }
    });

    unitsAsync.whenData((units) {
      for (final u in units) {
        markers.add(Marker(
          markerId: MarkerId('unit_${u.unitId}'),
          position: LatLng(u.currentLat, u.currentLng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            u.status == 'dispatched' ? BitmapDescriptor.hueOrange
            : u.status == 'on_scene' ? BitmapDescriptor.hueBlue
            : BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(title: '${u.typeIcon} ${u.name}', snippet: '${u.statusLabel}${u.etaMinutes != null ? " — ETA: ${u.etaMinutes}min" : ""}'),
        ));
      }
    });

    reroutesAsync.whenData((reroutes) {
      for (int i = 0; i < reroutes.length; i++) {
        final r = reroutes[i];
        final waypoints = r['waypoints'] as List? ?? [];
        if (waypoints.length >= 2) {
          polylines.add(Polyline(
            polylineId: PolylineId('reroute_$i'),
            points: waypoints.map((w) => LatLng((w['lat'] ?? 0).toDouble(), (w['lng'] ?? 0).toDouble())).toList(),
            color: AppColors.accentCyan, width: 4,
            patterns: [PatternItem.dash(20), PatternItem.gap(10)],
          ));
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(title: Text('LIVE OPERATIONS MAP', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700))),
      body: Column(children: [
        // Legend
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), color: AppColors.bgCard,
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            _legendItem('🔴', 'Crisis'), _legendItem('🟠', 'Dispatched'), _legendItem('🟢', 'Available'), _legendItem('🔵', 'Reroute'),
          ]),
        ),
        // Map
        Expanded(child: GoogleMap(
          initialCameraPosition: _initialCamera,
          onMapCreated: (c) => _controller = c,
          markers: markers, circles: circles, polylines: polylines,
          mapType: MapType.normal,
          myLocationEnabled: false, zoomControlsEnabled: true,
        )),
      ]),
    );
  }

  Widget _legendItem(String emoji, String label) {
    return Row(children: [
      Text(emoji, style: const TextStyle(fontSize: 12)),
      const SizedBox(width: 4),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
    ]);
  }
}
