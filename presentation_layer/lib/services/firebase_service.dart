import 'package:firebase_database/firebase_database.dart';
import '../models/crisis_model.dart';
import '../models/unit_model.dart';
import '../models/alert_model.dart';
import '../core/constants.dart';

class FirebaseService {
  final FirebaseDatabase _db = FirebaseDatabase.instance;

  Map<String, dynamic> _asStringMap(dynamic raw) {
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    return <String, dynamic>{};
  }

  // ── CRISIS STREAMS ────────────────────────────────────────────
  Stream<List<CrisisModel>> watchActiveCrises() {
    return _db
        .ref(FirebasePaths.activeCrises)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.values
          .map((v) => CrisisModel.fromMap(v as Map<dynamic, dynamic>))
          .where((c) => c.status == 'active')
          .toList()
          ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
    });
  }

  // ── UNIT STREAMS ──────────────────────────────────────────────
  Stream<List<UnitModel>> watchUnits() {
    return _db
        .ref(FirebasePaths.units)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries
          .map((e) => UnitModel.fromMap(e.key, e.value as Map<dynamic, dynamic>))
          .toList()
          ..sort((a, b) => a.name.compareTo(b.name));
    });
  }

  // ── ALERT STREAMS ─────────────────────────────────────────────
  Stream<List<AlertModel>> watchAlerts() {
    return _db
        .ref(FirebasePaths.alerts)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries
          .map((e) => AlertModel.fromMap(e.key, e.value as Map<dynamic, dynamic>))
          .toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    });
  }

  // ── AGENT LOG STREAMS ─────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> watchAgentLogs() {
    return _db
        .ref(FirebasePaths.agentLogs)
        .orderByChild('timestamp')
        .limitToLast(50)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.values
          .map((v) {
            final item = _asStringMap(v);
            final normalizedAgentName = (item['agent_name'] ?? item['agent'] ?? 'System').toString();
            item['agent_name'] = normalizedAgentName;
            return item;
          })
          .toList()
          ..sort((a, b) => (b['timestamp'] ?? '').compareTo(a['timestamp'] ?? ''));
    });
  }

  // Dispatch tickets stream
  Stream<List<Map<String, dynamic>>> watchDispatchTickets() {
    return _db.ref(FirebasePaths.dispatchTickets).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      final tickets = data.values.map((v) => _asStringMap(v)).toList();
      tickets.sort((a, b) {
        final aTime = (a['issued_at'] ?? a['sent_at'] ?? '').toString();
        final bTime = (b['issued_at'] ?? b['sent_at'] ?? '').toString();
        return bTime.compareTo(aTime);
      });
      return tickets;
    });
  }

  // Monitoring cycles stream
  Stream<List<Map<String, dynamic>>> watchMonitoringCycles() {
    return _db.ref(FirebasePaths.monitoringCycles).onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      final cycles = data.values.map((v) => _asStringMap(v)).toList();
      cycles.sort((a, b) {
        final aNo = a['cycle_number'] is num ? (a['cycle_number'] as num).toInt() : 0;
        final bNo = b['cycle_number'] is num ? (b['cycle_number'] as num).toInt() : 0;
        return bNo.compareTo(aNo);
      });
      return cycles;
    });
  }

  // ── SYSTEM STATE STREAM ───────────────────────────────────────
  Stream<Map<String, dynamic>> watchSystemState() {
    return _db
        .ref(FirebasePaths.systemState)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return {'mode': 'monitoring'};
      return Map<String, dynamic>.from(data);
    });
  }

  // ── OUTCOME METRICS STREAM ────────────────────────────────────
  Stream<Map<String, dynamic>> watchOutcomeMetrics() {
    return _db
        .ref(FirebasePaths.outcomeMetrics)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return {};
      return Map<String, dynamic>.from(data);
    });
  }

  // ── REROUTE STREAMS ───────────────────────────────────────────
  Stream<List<Map<String, dynamic>>> watchActiveReroutes() {
    return _db
        .ref(FirebasePaths.activeReroutes)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.values
          .map((v) => Map<String, dynamic>.from(v as Map))
          .where((r) => r['status'] == 'active')
          .toList();
    });
  }

  // ── WRITE OPERATIONS ──────────────────────────────────────────
  Future<void> acknowledgeAlert(String alertId) async {
    await _db.ref('${FirebasePaths.alerts}/$alertId/acknowledged').set(true);
  }
}
