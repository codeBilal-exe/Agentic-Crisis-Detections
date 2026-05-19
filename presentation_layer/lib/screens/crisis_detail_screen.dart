import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../core/constants.dart';
import '../providers/crisis_provider.dart';
import '../models/crisis_model.dart';

class CrisisDetailScreen extends ConsumerWidget {
  final String crisisId;
  const CrisisDetailScreen({super.key, required this.crisisId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crisesAsync = ref.watch(activeCrisesProvider);
    final metricsAsync = ref.watch(outcomeMetricsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(title: const Text('Crisis Detail')),
      body: crisesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (crises) {
          final crisis = crises.where((c) => c.crisisId == crisisId).firstOrNull;
          if (crisis == null) return const Center(child: Text('Crisis not found', style: TextStyle(color: AppColors.textSecondary)));
          return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(
              gradient: LinearGradient(colors: [crisis.severityColor.withOpacity(0.1), AppColors.bgCard]),
              borderRadius: BorderRadius.circular(16), border: Border.all(color: crisis.severityColor.withOpacity(0.4))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Text(crisis.crisisTypeIcon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(crisis.crisisTypeLabel, style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: crisis.severityColor, borderRadius: BorderRadius.circular(8)),
                    child: Text(crisis.severity, style: GoogleFonts.jetBrainsMono(fontSize: 12, fontWeight: FontWeight.w700, color: Colors.white))),
                ]),
                const SizedBox(height: 12),
                _detailRow('📍 Location', crisis.affectedAreaName),
                _detailRow('🕐 Detected', crisis.detectedAt),
                _detailRow('🎯 Confidence', '${(crisis.confidence * 100).toInt()}% (${crisis.confidenceLabel})'),
                _detailRow('👥 People at Risk', '~${crisis.estimatedPeopleAffected}'),
              ]),
            ),
            const SizedBox(height: 16),

            // AI Reasoning
            Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppColors.bgElevated, borderRadius: BorderRadius.circular(12),
              border: const Border(left: BorderSide(color: AppColors.accentCyan, width: 4))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('🤖 ANALYST ASSESSMENT', style: GoogleFonts.spaceGrotesk(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.accentCyan)),
                const SizedBox(height: 8),
                Text(crisis.reasoningSummary, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, fontStyle: FontStyle.italic, height: 1.5)),
              ]),
            ),
            const SizedBox(height: 16),

            // Impact Assessment
            Text('IMPACT ASSESSMENT', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              ...crisis.roadsBlocked.map((r) => Chip(label: Text(r, style: const TextStyle(fontSize: 11)), backgroundColor: AppColors.severityCritical.withOpacity(0.2),
                side: const BorderSide(color: AppColors.severityCritical), labelStyle: const TextStyle(color: AppColors.textPrimary))),
            ]),
            const SizedBox(height: 20),

            // Outcome Metrics
            metricsAsync.when(
              data: (metrics) {
                if (metrics.isEmpty) return const SizedBox();
                final before = Map<String, dynamic>.from(metrics['before'] ?? {});
                final after = Map<String, dynamic>.from(metrics['after'] ?? {});
                if (before.isEmpty && after.isEmpty) return const SizedBox();
                return _buildOutcomeChart(before, after, metrics['resolution_time_minutes'] ?? 0);
              },
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ]));
        },
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(padding: const EdgeInsets.only(bottom: 6),
      child: Row(children: [
        SizedBox(width: 120, child: Text(label, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary))),
        Expanded(child: Text(value, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500))),
      ]));
  }

  Widget _buildOutcomeChart(Map<String, dynamic> before, Map<String, dynamic> after, int resolutionMin) {
    final bCongestion = (before['congestion_level'] ?? 0).toDouble();
    final aCongestion = (after['congestion_level'] ?? 0).toDouble();
    final bStranded = (before['estimated_stranded_vehicles'] ?? 0).toDouble();
    final aStranded = (after['estimated_stranded_vehicles'] ?? 0).toDouble();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('OUTCOME METRICS — Before vs After', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      const SizedBox(height: 6),
      Text('Projected resolution: $resolutionMin min', style: GoogleFonts.inter(fontSize: 12, color: AppColors.accentCyan)),
      const SizedBox(height: 16),
      SizedBox(height: 220, child: BarChart(BarChartData(
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
            switch (v.toInt()) { case 0: return Text('Congestion %', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)); case 1: return Text('Stranded', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondary)); default: return const Text(''); }
          })),
          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: const FlGridData(show: false),
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(toY: bCongestion, color: AppColors.severityHigh, width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
            BarChartRodData(toY: aCongestion, color: AppColors.severityLow, width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(toY: bStranded, color: AppColors.severityHigh, width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
            BarChartRodData(toY: aStranded, color: AppColors.severityLow, width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
          ]),
        ],
      ))),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.severityHigh, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4), Text('Before', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
        const SizedBox(width: 16),
        Container(width: 12, height: 12, decoration: BoxDecoration(color: AppColors.severityLow, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 4), Text('After', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
      ]),
    ]);
  }
}
