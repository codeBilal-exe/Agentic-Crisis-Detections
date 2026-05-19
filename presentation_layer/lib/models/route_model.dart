class RouteModel {
  final String rerouteId;
  final String crisisId;
  final String blockedRoad;
  final String alternateRouteName;
  final String status;
  final String createdAt;
  final List<Map<String, double>> waypoints;

  RouteModel({
    required this.rerouteId,
    required this.crisisId,
    required this.blockedRoad,
    required this.alternateRouteName,
    required this.status,
    required this.createdAt,
    required this.waypoints,
  });

  factory RouteModel.fromMap(String id, Map<dynamic, dynamic> map) {
    List<Map<String, double>> wp = [];
    if (map['waypoints'] != null) {
      for (var w in map['waypoints']) {
        if (w is Map) {
          wp.add({
            'lat': (w['lat'] ?? 0.0).toDouble(),
            'lng': (w['lng'] ?? 0.0).toDouble(),
          });
        }
      }
    }
    return RouteModel(
      rerouteId: id,
      crisisId: map['crisis_id'] ?? '',
      blockedRoad: map['blocked_road'] ?? '',
      alternateRouteName: map['alternate_route_name'] ?? '',
      status: map['status'] ?? 'active',
      createdAt: map['created_at'] ?? '',
      waypoints: wp,
    );
  }
}
