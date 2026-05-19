import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase_service.dart';
import '../models/crisis_model.dart';
import '../models/unit_model.dart';
import '../models/alert_model.dart';

final firebaseServiceProvider = Provider<FirebaseService>((ref) => FirebaseService());

final activeCrisesProvider = StreamProvider<List<CrisisModel>>((ref) {
  return ref.watch(firebaseServiceProvider).watchActiveCrises();
});

final unitsProvider = StreamProvider<List<UnitModel>>((ref) {
  return ref.watch(firebaseServiceProvider).watchUnits();
});

final alertsProvider = StreamProvider<List<AlertModel>>((ref) {
  return ref.watch(firebaseServiceProvider).watchAlerts();
});

final agentLogsProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(firebaseServiceProvider).watchAgentLogs();
});

final systemStateProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return ref.watch(firebaseServiceProvider).watchSystemState();
});

final outcomeMetricsProvider = StreamProvider<Map<String, dynamic>>((ref) {
  return ref.watch(firebaseServiceProvider).watchOutcomeMetrics();
});

final activeReroutesProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.watch(firebaseServiceProvider).watchActiveReroutes();
});
