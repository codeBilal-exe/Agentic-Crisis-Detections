import 'package:flutter/material.dart';
import '../core/constants.dart';

class UnitModel {
  final String unitId;
  final String name;
  final String type;
  final String status;
  final double baseLat;
  final double baseLng;
  final double currentLat;
  final double currentLng;
  final String? destination;
  final int? etaMinutes;
  final String? assignedCrisisId;

  UnitModel({
    required this.unitId, required this.name, required this.type,
    required this.status, required this.baseLat, required this.baseLng,
    required this.currentLat, required this.currentLng,
    this.destination, this.etaMinutes, this.assignedCrisisId,
  });

  factory UnitModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return UnitModel(
      unitId: id,
      name: map['name'] ?? '',
      type: map['type'] ?? 'general_rescue',
      status: map['status'] ?? 'available',
      baseLat: (map['base_lat'] ?? 0.0).toDouble(),
      baseLng: (map['base_lng'] ?? 0.0).toDouble(),
      currentLat: (map['current_lat'] ?? 0.0).toDouble(),
      currentLng: (map['current_lng'] ?? 0.0).toDouble(),
      destination: map['destination'],
      etaMinutes: map['eta_minutes'],
      assignedCrisisId: map['assigned_crisis_id'],
    );
  }

  Color get statusColor {
    switch (status) {
      case 'available':  return AppColors.statusAvailable;
      case 'dispatched': return AppColors.statusDispatched;
      case 'on_scene':   return AppColors.statusOnScene;
      default:           return AppColors.severityNone;
    }
  }

  String get typeIcon {
    switch (type) {
      case 'flood_rescue':    return '🚤';
      case 'medical':         return '🚑';
      case 'fire':            return '🚒';
      case 'pdma_assessment': return '📋';
      default:                return '🚐';
    }
  }

  String get statusLabel {
    switch (status) {
      case 'available':  return 'AVAILABLE';
      case 'dispatched': return 'DISPATCHED';
      case 'on_scene':   return 'ON SCENE';
      case 'returning':  return 'RETURNING';
      case 'standby':    return 'STANDBY';
      default:           return status.toUpperCase();
    }
  }

  String get typeLabel {
    switch (type) {
      case 'general_rescue':  return 'General Rescue';
      case 'flood_rescue':    return 'Flood Rescue';
      case 'medical':         return 'Medical';
      case 'fire':            return 'Fire';
      case 'pdma_assessment': return 'PDMA Assessment';
      default:                return type;
    }
  }
}
