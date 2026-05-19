import 'package:flutter/material.dart';
import '../core/constants.dart';

class CrisisModel {
  final String crisisId;
  final String crisisType;
  final String severity;
  final double confidence;
  final String confidenceLabel;
  final String detectedAt;
  final String affectedAreaName;
  final double affectedLat;
  final double affectedLng;
  final double affectedRadiusKm;
  final List<String> roadsBlocked;
  final int estimatedPeopleAffected;
  final String status;
  final String reasoningSummary;
  final String? planId;

  CrisisModel({
    required this.crisisId,
    required this.crisisType,
    required this.severity,
    required this.confidence,
    required this.confidenceLabel,
    required this.detectedAt,
    required this.affectedAreaName,
    required this.affectedLat,
    required this.affectedLng,
    required this.affectedRadiusKm,
    required this.roadsBlocked,
    required this.estimatedPeopleAffected,
    required this.status,
    required this.reasoningSummary,
    this.planId,
  });

  factory CrisisModel.fromMap(Map<dynamic, dynamic> map) {
    return CrisisModel(
      crisisId: map['crisis_id'] ?? '',
      crisisType: map['crisis_type'] ?? 'unknown',
      severity: map['severity'] ?? 'LOW',
      confidence: (map['confidence'] ?? 0.0).toDouble(),
      confidenceLabel: map['confidence_label'] ?? 'LOW',
      detectedAt: map['detected_at'] ?? '',
      affectedAreaName: map['affected_area_name'] ?? '',
      affectedLat: (map['affected_lat'] ?? 0.0).toDouble(),
      affectedLng: (map['affected_lng'] ?? 0.0).toDouble(),
      affectedRadiusKm: (map['affected_radius_km'] ?? 1.0).toDouble(),
      roadsBlocked: List<String>.from(map['roads_blocked'] ?? []),
      estimatedPeopleAffected: map['estimated_people_affected'] ?? 0,
      status: map['status'] ?? 'active',
      reasoningSummary: map['reasoning_summary'] ?? '',
      planId: map['plan_id'],
    );
  }

  Color get severityColor {
    switch (severity) {
      case 'CRITICAL': return AppColors.severityCritical;
      case 'HIGH':     return AppColors.severityHigh;
      case 'MEDIUM':   return AppColors.severityMedium;
      case 'LOW':      return AppColors.severityLow;
      default:         return AppColors.severityNone;
    }
  }

  String get crisisTypeLabel {
    switch (crisisType) {
      case 'urban_flooding':        return 'Urban Flooding';
      case 'road_accident':         return 'Road Accident';
      case 'heatwave':              return 'Heatwave';
      case 'infrastructure_failure': return 'Infrastructure Failure';
      default:                      return 'Unknown Event';
    }
  }

  String get crisisTypeIcon {
    switch (crisisType) {
      case 'urban_flooding':        return '🌊';
      case 'road_accident':         return '🚗';
      case 'heatwave':              return '🌡️';
      case 'infrastructure_failure': return '⚡';
      default:                      return '⚠️';
    }
  }
}
