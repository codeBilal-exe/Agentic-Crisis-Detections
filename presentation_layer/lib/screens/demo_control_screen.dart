import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../services/api_service.dart';
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
        title: const Text('DEMO CONTROL PANEL'),
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
                Text('CIRO SIMULATION ENGINE', style: GoogleFonts.spaceGrotesk(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                const Text('Select a crisis scenario to inject signals', style: TextStyle(color: AppColors.textSecondary)),
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
                  return const Center(child: Text('Failed to load scenarios'));
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
                                        title: const Text('Scenario Triggered'),
                                        content: const Text('Injected signals. Now run the Antigravity pipeline.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(c);
                                              context.go('/dashboard');
                                            },
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                },
                                style: ElevatedButton.styleFrom(backgroundColor: AppColors.accentBlue),
                                child: _isLoading 
                                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                    : const Text('TRIGGER'),
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
                const Text('PIPELINE STATUS', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: () async {
                      await ApiService.post(ApiEndpoints.resetSimulation);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('System Reset Complete')));
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.severityCritical),
                    child: const Text('RESET ALL SYSTEMS'),
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
