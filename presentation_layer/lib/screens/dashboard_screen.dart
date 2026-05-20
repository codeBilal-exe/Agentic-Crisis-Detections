import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../core/constants.dart';
import '../models/crisis_model.dart';
import '../providers/crisis_provider.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import '../widgets/crisis_card.dart';
import '../widgets/language_toggle_button.dart';
import '../widgets/stat_tile.dart';
import '../widgets/unit_mini_card.dart';
import '../models/unit_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageProviderState = ref.watch(languageProvider);
    final isUrdu = languageProviderState == AppLanguage.urdu;
    final systemState = ref.watch(systemStateProvider);
    final units = ref.watch(unitsProvider);
    final dispatchTickets = ref.watch(dispatchTicketsProvider);
    final agentLogs = ref.watch(agentLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(ref, 'dashboard_title'), style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        actions: const [LanguageToggleButton()],
      ),
      body: Column(
        children: [
          _buildStatusBar(systemState, ref),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: isUrdu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  StreamBuilder<DatabaseEvent>(
                    stream: FirebaseDatabase.instance.ref(FirebasePaths.activeCrises).onValue,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildShimmerBox(140);
                      }
                      if (snapshot.hasError) {
                        return _buildStatusMessage(tr(ref, 'loading_error'));
                      }

                      final rawData = snapshot.data?.snapshot.value as Map<dynamic, dynamic>?;
                      final crises = _parseCrises(rawData);
                      final activeCrisisCount = crises.length;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSummaryRow(activeCrisisCount, units, ref),
                          const SizedBox(height: 24),
                          Text(tr(ref, 'active_crises'), style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 12),
                          if (crises.isEmpty)
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(24.0),
                                child: Center(
                                  child: Text(tr(ref, 'all_clear'), style: Theme.of(context).textTheme.bodyMedium),
                                ),
                              ),
                            )
                          else
                            Column(
                              children: crises
                                  .map((crisis) => Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: CrisisCard(crisis: crisis),
                                      ))
                                  .toList(),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(tr(ref, 'response_units_title'), style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  units.when(
                    data: (u) {
                      if (u.isEmpty) {
                        return _buildStatusMessage(tr(ref, 'no_units_available'));
                      }
                      return GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 2.5,
                        ),
                        itemCount: u.length,
                        itemBuilder: (context, index) => UnitMiniCard(unit: u[index]),
                      );
                    },
                    loading: () => _buildShimmerBox(100),
                    error: (e, st) => _buildStatusMessage(tr(ref, 'loading_error')),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('AUTHORITY COORDINATION', style: Theme.of(context).textTheme.titleLarge),
                      TextButton.icon(
                        onPressed: () => context.push('/dispatch-tickets'),
                        icon: const Icon(Icons.confirmation_number_outlined, size: 18),
                        label: const Text('VIEW TICKETS'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  dispatchTickets.when(
                    data: (tickets) => _buildAuthorityCoordinationPanel(tickets),
                    loading: () => _buildShimmerBox(72),
                    error: (e, st) => _buildStatusMessage(tr(ref, 'loading_error')),
                  ),
                  const SizedBox(height: 24),
                  Text(tr(ref, 'recent_agent_activity'), style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  agentLogs.when(
                    data: (logs) {
                      final recentLogs = logs.take(3).toList();
                      return Column(
                        children: recentLogs
                            .map((log) => ListTile(
                                  title: Text(log['agent_name'] ?? 'System', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text(log['message'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                                  leading: const Icon(Icons.psychology, color: AppColors.accentCyan),
                                ))
                            .toList(),
                      );
                    },
                    loading: () => _buildShimmerBox(100),
                    error: (e, st) => _buildStatusMessage(tr(ref, 'loading_error')),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        backgroundColor: AppColors.bgCard,
        selectedItemColor: AppColors.accentBlue,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/dashboard');
              break;
            case 1:
              context.go('/map');
              break;
            case 2:
              context.go('/units');
              break;
            case 3:
              context.go('/alerts');
              break;
            case 4:
              context.go('/agent-logs');
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: const Icon(Icons.dashboard), label: tr(ref, 'navigation_dashboard')),
          BottomNavigationBarItem(icon: const Icon(Icons.map), label: tr(ref, 'navigation_map')),
          BottomNavigationBarItem(icon: const Icon(Icons.local_shipping), label: tr(ref, 'navigation_units')),
          BottomNavigationBarItem(icon: const Icon(Icons.notifications), label: tr(ref, 'navigation_alerts')),
          BottomNavigationBarItem(icon: const Icon(Icons.terminal), label: tr(ref, 'navigation_logs')),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.severityCritical,
        icon: const Icon(Icons.rocket_launch, color: Colors.white),
        label: Text(tr(ref, 'simulate_button'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _triggerSimulation(context),
      ),
    );
  }

  Widget _buildStatusBar(AsyncValue<Map<String, dynamic>> systemState, WidgetRef ref) {
    return systemState.when(
      data: (state) {
        final mode = state['mode'] ?? 'monitoring';
        if (mode == 'crisis_active') {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.severityCritical,
            child: Text(
              tr(ref, 'system_crisis_active'),
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.5, end: 1.0);
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          color: AppColors.accentBlue,
          child: Text(
            tr(ref, 'system_monitoring'),
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        );
      },
      loading: () => const SizedBox(height: 48),
      error: (_, __) => const SizedBox(height: 48),
    );
  }

  Widget _buildSummaryRow(int activeCrisisCount, AsyncValue<List<UnitModel>> units, WidgetRef ref) {
    return units.when(
      data: (unitList) {
        final available = unitList.where((u) => u.status == 'available').length.toString();
        final dispatched = unitList.where((u) => u.status == 'dispatched').length.toString();

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: StatTile(
                label: tr(ref, 'active_crises_count'),
                value: activeCrisisCount.toString(),
                icon: Icons.warning_amber_rounded,
                color: AppColors.severityCritical,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                label: tr(ref, 'available_units'),
                value: available,
                icon: Icons.shield,
                color: AppColors.statusAvailable,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatTile(
                label: tr(ref, 'dispatched_units'),
                value: dispatched,
                icon: Icons.local_shipping,
                color: AppColors.statusDispatched,
              ),
            ),
          ],
        );
      },
      loading: () => _buildShimmerBox(100),
      error: (_, __) => _buildStatusMessage(tr(ref, 'loading_error')),
    );
  }

  Widget _buildShimmerBox(double height) {
    return Shimmer.fromColors(
      baseColor: AppColors.bgCard,
      highlightColor: AppColors.bgElevated,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Widget _buildStatusMessage(String text) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text(text, style: const TextStyle(color: AppColors.textSecondary)),
        ),
      ),
    );
  }

  List<CrisisModel> _parseCrises(Map<dynamic, dynamic>? rawData) {
    if (rawData == null) return [];
    return rawData.values
        .map((item) => CrisisModel.fromMap(item as Map<dynamic, dynamic>))
        .where((crisis) => crisis.status == 'active')
        .toList()
      ..sort((a, b) => b.detectedAt.compareTo(a.detectedAt));
  }

  Future<void> _triggerSimulation(BuildContext context) async {
    final response = await ApiService.post('${ApiEndpoints.triggerScenario}/urban_flood_g10');
    if (!context.mounted) return;

    final message = response['error'] == true
        ? 'Simulation trigger failed: ${response['message'] ?? 'Unknown error'}'
        : 'Simulation triggered successfully';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget _buildAuthorityCoordinationPanel(List<Map<String, dynamic>> tickets) {
    final grouped = <String, String>{};
    for (final ticket in tickets) {
      final authority = (ticket['authority'] ?? ticket['authority_type'] ?? '').toString().toUpperCase();
      if (authority.isEmpty) continue;
      final status = (ticket['status'] ?? 'ISSUED').toString().toUpperCase();
      grouped[authority] = _deriveAuthorityState(status);
    }

    const defaults = <String, String>{
      'POLICE': 'NOTIFIED',
      'FIRE': 'STANDBY',
      'PDMA': 'ACTIVE',
    };
    defaults.forEach((key, value) => grouped.putIfAbsent(key, () => value));

    final cards = grouped.entries.take(3).toList();
    return Row(
      children: cards.map((entry) {
        final state = entry.value;
        final color = _coordinationColor(state);
        return Expanded(
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.bgCard,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: color.withValues(alpha: 0.7)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.key, style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  state,
                  style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  String _deriveAuthorityState(String status) {
    if (status == 'ON_SCENE' || status == 'UNITS_DISPATCHED') return 'ACTIVE';
    if (status == 'ACKNOWLEDGED') return 'STANDBY';
    return 'NOTIFIED';
  }

  Color _coordinationColor(String state) {
    switch (state) {
      case 'ACTIVE':
        return AppColors.statusAvailable;
      case 'STANDBY':
        return AppColors.statusDispatched;
      default:
        return AppColors.accentBlue;
    }
  }
}
