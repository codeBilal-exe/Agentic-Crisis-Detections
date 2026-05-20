import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../providers/language_provider.dart';
import '../services/api_service.dart';
import '../widgets/language_toggle_button.dart';
import '../widgets/severity_badge.dart';

class DemoControlScreen extends ConsumerStatefulWidget {
  const DemoControlScreen({super.key});

  @override
  ConsumerState<DemoControlScreen> createState() => _DemoControlScreenState();
}

class _DemoControlScreenState extends ConsumerState<DemoControlScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(tr(ref, 'demo_control_title')),
        actions: const [LanguageToggleButton()],
        backgroundColor: AppColors.bgElevated,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.borderSubtle, height: 1),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(tr(ref, 'scenario_engine'), style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(tr(ref, 'scenario_instruction'), style: const TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: ApiService.get(ApiEndpoints.listScenarios),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError || (snapshot.data != null && snapshot.data!['error'] == true)) {
                  return Center(child: Text(tr(ref, 'failed_to_load_scenarios')));
                }

                final scenarios = (snapshot.data!['scenarios'] as List?) ?? [];
                
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: scenarios.length,
                  itemBuilder: (context, index) {
                    final s = scenarios[index];
                    Color sevColor = AppColors.severityLow;
                    if (s['severity'] == 'CRITICAL') sevColor = AppColors.severityCritical;
                    if (s['severity'] == 'HIGH') sevColor = AppColors.severityHigh;
                    if (s['severity'] == 'MEDIUM') sevColor = AppColors.severityMedium;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: sevColor.withValues(alpha: 0.5)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(child: Text(s['scenario_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))),
                                SeverityBadge(severity: s['severity'] ?? 'LOW'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on, size: 14, color: AppColors.textSecondary),
                                const SizedBox(width: 4),
                                Text(s['location'] ?? '', style: const TextStyle(color: AppColors.textSecondary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(s['description'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : () async {
                                  setState(() => _isLoading = true);
                                  await ApiService.post('${ApiEndpoints.triggerScenario}/${s['scenario_id']}');
                                  if (!context.mounted) return;
                                  setState(() => _isLoading = false);
                                  
                                  showDialog(
                                    context: context,
                                    builder: (c) => AlertDialog(
                                        backgroundColor: AppColors.bgElevated,
                                        title: Text(tr(ref, 'scenario_triggered_title')),
                                        content: Text(tr(ref, 'scenario_triggered_message')),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(c);
                                              context.go('/dashboard');
                                            },
                                            child: Text(tr(ref, 'scenario_triggered_ok')),
                                          ),
                                        ],
                                      ),
                                    );
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentBlue),
                                child: _isLoading 
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : Text(tr(ref, 'trigger')),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          const Divider(height: 1, color: AppColors.borderSubtle),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(tr(ref, 'pipeline_status'), style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      final response = await ApiService.post(ApiEndpoints.seedPhase3);
                      if (!context.mounted) return;
                      final msg = response['error'] == true
                          ? 'Phase 3 seed failed'
                          : 'Phase 3 demo data seeded';
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentBlue),
                    child: const Text('SEED PHASE 3 DATA'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ApiService.post(ApiEndpoints.resetSimulation);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr(ref, 'systems_reset_complete'))));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.severityCritical),
                    child: Text(tr(ref, 'reset_all_systems')),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
