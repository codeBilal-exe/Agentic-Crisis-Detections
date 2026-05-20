import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../providers/crisis_provider.dart';

class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends ConsumerState<MapScreen> {
  GoogleMapController? _mapController;
  final String _mapStyle = '[{"elementType":"geometry","stylers":[{"color":"#080C14"}]},{"elementType":"labels.text.fill","stylers":[{"color":"#4A6080"}]},{"elementType":"labels.text.stroke","stylers":[{"color":"#080C14"}]},{"featureType":"road","elementType":"geometry","stylers":[{"color":"#1A2744"}]},{"featureType":"water","elementType":"geometry","stylers":[{"color":"#0A1628"}]},{"featureType":"poi","stylers":[{"visibility":"off"}]},{"featureType":"transit","stylers":[{"visibility":"off"}]}]';

  int _previousCrisisCount = 0;

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final crises = ref.watch(activeCrisesProvider);
    final units = ref.watch(unitsProvider);
    final reroutes = ref.watch(activeReroutesProvider);

    Set<Circle> circles = {};
    Set<Marker> markers = {};
    Set<Polyline> polylines = {};

    crises.whenData((data) {
      if (data.isNotEmpty && _previousCrisisCount == 0 && _mapController != null) {
        final firstCrisis = data.first;
        _mapController!.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(firstCrisis.affectedLat, firstCrisis.affectedLng),
              zoom: 13.5,
            ),
          ),
        );
      }
      _previousCrisisCount = data.length;

      for (var c in data) {
        circles.add(
          Circle(
            circleId: CircleId(c.crisisId),
            center: LatLng(c.affectedLat, c.affectedLng),
            radius: c.affectedRadiusKm * 1000,
            fillColor: c.severityColor.withValues(alpha: 0.2),
            strokeColor: c.severityColor,
            strokeWidth: 2,
          ),
        );
      }
    });

    units.whenData((data) {
      for (var u in data) {
        markers.add(
          Marker(
            markerId: MarkerId(u.unitId),
            position: LatLng(u.currentLat, u.currentLng),
            infoWindow: InfoWindow(title: u.name, snippet: u.statusLabel),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              u.status == 'dispatched' || u.status == 'on_scene' ? BitmapDescriptor.hueOrange : BitmapDescriptor.hueGreen,
            ),
          ),
        );
      }
    });

    reroutes.whenData((data) {
      for (var r in data) {
        final waypointsList = r['waypoints'] as List?;
        if (waypointsList != null) {
          List<LatLng> points = [];
          for (var w in waypointsList) {
            points.add(LatLng(w['lat'], w['lng']));
          }
          polylines.add(
            Polyline(
              polylineId: PolylineId(r['id'] ?? r.hashCode.toString()),
              points: points,
              color: Colors.orange,
              width: 4,
            ),
          );
        }
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('CRISIS MAP')),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(33.6844, 73.0479),
          zoom: 11,
        ),
        style: _mapStyle,
        circles: circles,
        markers: markers,
        polylines: polylines,
        myLocationEnabled: false,
        zoomControlsEnabled: false,
      ),
    );
  }
}
