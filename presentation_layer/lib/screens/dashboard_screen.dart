import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';
import '../core/constants.dart';
import '../providers/crisis_provider.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import '../widgets/crisis_card.dart';
import '../widgets/unit_mini_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageProviderState = ref.watch(languageProvider);
    final isUrdu = languageProviderState == AppLanguage.urdu;
    final systemState = ref.watch(systemStateProvider);
    final activeCrises = ref.watch(activeCrisesProvider);
    final units = ref.watch(unitsProvider);
    final agentLogs = ref.watch(agentLogsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('CIRO', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Text(
              isUrdu ? 'EN' : 'اردو',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              ref.read(languageProvider.notifier).toggleLanguage();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildStatusBar(systemState),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Active Crises', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  activeCrises.when(
                    data: (crises) {
                      if (crises.isEmpty) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: Text('All Clear — No active crises', style: Theme.of(context).textTheme.bodyMedium),
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: crises.map((crisis) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: CrisisCard(crisis: crisis),
                        )).toList(),
                      );
                    },
                    loading: () => _buildShimmerBox(100),
                    error: (e, st) => Text('Error loading crises'),
                  ),
                  const SizedBox(height: 24),
                  Text('Response Units', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  units.when(
                    data: (u) {
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
                    error: (e, st) => Text('Error loading units'),
                  ),
                  const SizedBox(height: 24),
                  Text('Recent Agent Activity', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  agentLogs.when(
                    data: (logs) {
                      final recentLogs = logs.take(3).toList();
                      return Column(
                        children: recentLogs.map((log) => ListTile(
                          title: Text(log['agent_name'] ?? 'System', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(log['message'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                          leading: const Icon(Icons.psychology, color: AppColors.accentCyan),
                        )).toList(),
                      );
                    },
                    loading: () => _buildShimmerBox(100),
                    error: (e, st) => Text('Error loading logs'),
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
            case 0: context.go('/dashboard'); break;
            case 1: context.go('/map'); break;
            case 2: context.go('/units'); break;
            case 3: context.go('/alerts'); break;
            case 4: context.go('/agent-logs'); break;
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: 'Units'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alerts'),
          BottomNavigationBarItem(icon: Icon(Icons.terminal), label: 'Logs'),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.severityCritical,
        icon: const Icon(Icons.rocket_launch, color: Colors.white),
        label: const Text('SIMULATE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => _showSimulationSheet(context, ref),
      ),
    );
  }

  Widget _buildStatusBar(AsyncValue<Map<String, dynamic>> systemState) {
    return systemState.when(
      data: (state) {
        final mode = state['mode'] ?? 'monitoring';
        if (mode == 'crisis_active') {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.severityCritical,
            child: Text(
              'CRISIS ACTIVE — INCIDENT(S) DETECTED',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.5, end: 1.0);
        } else if (mode == 'simulation') {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.purple,
            child: Text(
              'SIMULATION MODE',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        } else {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8),
            color: AppColors.accentBlue,
            child: Text(
              'MONITORING — ALL SYSTEMS NOMINAL',
              textAlign: TextAlign.center,
              style: GoogleFonts.jetBrainsMono(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          );
        }
      },
      loading: () => const SizedBox(),
      error: (_, __) => const SizedBox(),
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

  void _showSimulationSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgDeep,
      isScrollControlled: true,
      builder: (context) {
        return FutureBuilder<Map<String, dynamic>>(
          future: ApiService.get(ApiEndpoints.listScenarios),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 200,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            if (snapshot.hasError || (snapshot.data != null && snapshot.data!['error'] == true)) {
              return const SizedBox(
                height: 200,
                child: Center(child: Text('Failed to load scenarios')),
              );
            }

            final scenarios = (snapshot.data!['scenarios'] as List?) ?? [];
            return Container(
              padding: const EdgeInsets.all(16),
              height: MediaQuery.of(context).size.height * 0.7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Simulation Scenarios', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: scenarios.length,
                      itemBuilder: (context, index) {
                        final s = scenarios[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(s['scenario_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(s['location'] ?? ''),
                            trailing: ElevatedButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Activating scenario...')));
                                await ApiService.post('${ApiEndpoints.triggerScenario}/${s['scenario_id']}');
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Scenario Activated — Run Pipeline')));
                              },
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentBlue),
                              child: const Text('TRIGGER'),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        Navigator.pop(context);
                        await ApiService.post(ApiEndpoints.resetSimulation);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('System Reset Complete')));
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.severityCritical),
                      child: const Text('RESET SYSTEM'),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
