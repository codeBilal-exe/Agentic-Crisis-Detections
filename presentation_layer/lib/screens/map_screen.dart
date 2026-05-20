import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../core/constants.dart';
import '../providers/crisis_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle_button.dart';

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
    controller.setMapStyle(_mapStyle);
  }

  @override
  Widget build(BuildContext context) {
    final crises = ref.watch(activeCrisesProvider);
    final units = ref.watch(unitsProvider);
    final reroutes = ref.watch(activeReroutesProvider);

    final bool isLoading = crises.isLoading || units.isLoading || reroutes.isLoading;
    final bool hasCrisis = crises.asData?.value.isNotEmpty ?? false;

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
        final crisisPosition = LatLng(c.affectedLat, c.affectedLng);
        circles.add(
          Circle(
            circleId: CircleId(c.crisisId),
            center: crisisPosition,
            radius: c.affectedRadiusKm * 1000,
            fillColor: c.severityColor.withValues(alpha: 0.2),
            strokeColor: c.severityColor,
            strokeWidth: 2,
          ),
        );
        markers.add(
          Marker(
            markerId: MarkerId('crisis-${c.crisisId}'),
            position: crisisPosition,
            infoWindow: InfoWindow(
              title: c.crisisTypeLabel,
              snippet: c.affectedAreaName,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              c.severity == 'CRITICAL'
                  ? BitmapDescriptor.hueRed
                  : c.severity == 'HIGH'
                      ? BitmapDescriptor.hueOrange
                      : c.severity == 'MEDIUM'
                          ? BitmapDescriptor.hueYellow
                          : BitmapDescriptor.hueAzure,
            ),
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
      appBar: AppBar(
        title: Text(tr(ref, 'map_title')),
        actions: const [LanguageToggleButton()],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: const CameraPosition(
              target: LatLng(33.6844, 73.0479),
              zoom: 11,
            ),
            circles: circles,
            markers: markers,
            polylines: polylines,
            myLocationEnabled: false,
            zoomControlsEnabled: false,
          ),
          if (isLoading)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 2,
                color: AppColors.bgCard.withOpacity(0.92),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.accentBlue),
                      ),
                      const SizedBox(width: 12),
                      Text(tr(ref, 'loading_map_data'), style: const TextStyle(color: AppColors.textPrimary)),
                    ],
                  ),
                ),
              ),
            ),
          if (!isLoading && !hasCrisis)
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: Card(
                color: AppColors.bgCard.withOpacity(0.95),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    tr(ref, 'all_clear'),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: hasCrisis
          ? FloatingActionButton(
              onPressed: () {
                final centerCrisis = crises.asData?.value.first;
                if (centerCrisis != null && _mapController != null) {
                  _mapController!.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: LatLng(centerCrisis.affectedLat, centerCrisis.affectedLng),
                        zoom: 13.5,
                      ),
                    ),
                  );
                }
              },
              backgroundColor: AppColors.accentBlue,
              child: const Icon(Icons.my_location),
            )
          : null,
    );
  }
}
