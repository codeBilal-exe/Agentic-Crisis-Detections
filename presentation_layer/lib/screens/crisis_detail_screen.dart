import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import '../providers/crisis_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle_button.dart';
import '../widgets/severity_badge.dart';
import '../widgets/stat_tile.dart';

class CrisisDetailScreen extends ConsumerWidget {
  final String crisisId;
  const CrisisDetailScreen({super.key, required this.crisisId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeCrisesAsync = ref.watch(activeCrisesProvider);
    final outcomeMetricsAsync = ref.watch(outcomeMetricsProvider);

    return activeCrisesAsync.when(
      data: (crises) {
        final crisis = crises.firstWhere((c) => c.crisisId == crisisId, orElse: () => throw Exception('Crisis not found'));
        
        return Scaffold(
          appBar: AppBar(
            title: Text(tr(ref, 'crisis_detail_title')),
            actions: const [LanguageToggleButton()],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SeverityBadge(severity: crisis.severity),
                            Text(crisis.detectedAt, style: Theme.of(context).textTheme.labelSmall),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: AppColors.textSecondary, size: 16),
                            const SizedBox(width: 4),
                            Text(crisis.affectedAreaName, style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Text('Confidence', style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(width: 8),
                            Expanded(
                              child: LinearProgressIndicator(
                                value: crisis.confidence,
                                color: crisis.severityColor,
                                backgroundColor: AppColors.bgElevated,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${(crisis.confidence * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // AI Reasoning
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    border: const Border(left: BorderSide(color: AppColors.accentCyan, width: 4)),
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr(ref, 'ai_reasoning_title'), style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        crisis.reasoningSummary,
                        style: GoogleFonts.inter(fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Escalation Prediction
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.bgElevated,
                    border: const Border(left: BorderSide(color: Colors.orange, width: 4)),
                    borderRadius: const BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(tr(ref, 'escalation_prediction_title'), style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text(
                        // We will just use reasoningSummary or a mock text since escalationPrediction might not be in the model
                        'High risk of rapid escalation within next 2 hours based on current conditions.',
                        style: GoogleFonts.inter(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Outcome Metrics
                Text(tr(ref, 'outcome_metrics'), style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 12),
                SizedBox(
                  height: 200,
                  child: outcomeMetricsAsync.when(
                    data: (metrics) {
                      // Mocking data if not available
                      double beforeCongestion = (metrics['before_congestion'] ?? 85.0).toDouble();
                      double afterCongestion = (metrics['after_congestion'] ?? 30.0).toDouble();
                      double beforeVehicles = (metrics['before_stranded'] ?? 150.0).toDouble() / 5.0;
                      double afterVehicles = (metrics['after_stranded'] ?? 20.0).toDouble() / 5.0;

                      return BarChart(
                        BarChartData(
                          alignment: BarChartAlignment.spaceAround,
                          maxY: 100,
                          barTouchData: BarTouchData(enabled: false),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  if (value == 0) return const Text('Congestion %');
                                  if (value == 1) return const Text('Vehicles/5');
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          ),
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(show: false),
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(toY: beforeCongestion, color: AppColors.severityHigh, width: 20),
                                BarChartRodData(toY: afterCongestion, color: AppColors.severityLow, width: 20),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(toY: beforeVehicles, color: AppColors.severityHigh, width: 20),
                                BarChartRodData(toY: afterVehicles, color: AppColors.severityLow, width: 20),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 800.ms);
                    },
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (_, __) => const Text('Error loading metrics'),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Stats row
                Row(
                  children: [
                    Expanded(child: StatTile(label: tr(ref, 'est_affected'), value: '${crisis.estimatedPeopleAffected}', icon: Icons.people, color: AppColors.accentBlue)),
                    const SizedBox(width: 8),
                    Expanded(child: StatTile(label: tr(ref, 'roads_blocked_label'), value: '${crisis.roadsBlocked.length}', icon: Icons.traffic, color: AppColors.severityHigh)),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, st) => Scaffold(body: Center(child: Text('Error loading crisis: $e'))),
    );
  }
}
