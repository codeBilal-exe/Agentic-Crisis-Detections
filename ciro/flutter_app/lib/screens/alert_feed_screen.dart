import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../providers/crisis_provider.dart';
import '../models/alert_model.dart';

class AlertFeedScreen extends ConsumerWidget {
  const AlertFeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsProvider);
    final fbService = ref.watch(firebaseServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: Row(children: [
          Text('ACTIVE ALERTS', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          alertsAsync.whenOrNull(data: (alerts) {
            final unack = alerts.where((a) => !a.acknowledged).length;
            return unack > 0 ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.severityCritical, borderRadius: BorderRadius.circular(10)),
              child: Text('$unack', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white))) : const SizedBox();
          }) ?? const SizedBox(),
        ]),
      ),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (alerts) {
          if (alerts.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.notifications_none, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: 12),
            Text('No Active Alerts', style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary)),
          ]));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: alerts.length,
            itemBuilder: (ctx, i) => _buildAlertCard(alerts[i], fbService).animate().fadeIn(delay: (i * 100).ms, duration: 300.ms).slideY(begin: -0.05, end: 0),
          );
        },
      ),
    );
  }

  Widget _buildAlertCard(AlertModel alert, dynamic fbService) {
    final severityColor = _getSeverityColor(alert.severity);
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: alert.acknowledged ? AppColors.bgCard.withOpacity(0.6) : AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: severityColor, width: 4)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: severityColor, borderRadius: BorderRadius.circular(6)),
            child: Text('${alert.severity} SEVERITY', style: GoogleFonts.jetBrainsMono(fontSize: 9, fontWeight: FontWeight.w700, color: Colors.white))),
          const Spacer(),
          Text(_formatTimestamp(alert.createdAt), style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppColors.textTertiary)),
        ]),
        const SizedBox(height: 10),
        Text(alert.title, style: GoogleFonts.spaceGrotesk(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        const SizedBox(height: 6),
        Text(alert.body, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondary, height: 1.4)),
        const Divider(color: AppColors.borderSubtle, height: 20),
        // Urdu text
        Directionality(
          textDirection: TextDirection.rtl,
          child: Text(alert.urduBody.isNotEmpty ? '[اردو] ${alert.urduBody}' : '', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
        ),
        const SizedBox(height: 10),
        // Channel pills
        Wrap(spacing: 6, children: alert.channelsSent.map((ch) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(color: AppColors.bgElevated, borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.borderSubtle)),
          child: Text(ch.replaceAll('_', '-'), style: GoogleFonts.jetBrainsMono(fontSize: 9, color: AppColors.textSecondary)),
        )).toList()),
        if (!alert.acknowledged) ...[
          const SizedBox(height: 10),
          SizedBox(width: double.infinity, child: OutlinedButton(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.accentBlue, side: const BorderSide(color: AppColors.accentBlue)),
            onPressed: () => fbService.acknowledgeAlert(alert.alertId),
            child: const Text('MARK ACKNOWLEDGED'),
          )),
        ],
      ]),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'CRITICAL': return AppColors.severityCritical;
      case 'HIGH': return AppColors.severityHigh;
      case 'MEDIUM': return AppColors.severityMedium;
      case 'LOW': return AppColors.severityLow;
      default: return AppColors.severityNone;
    }
  }

  String _formatTimestamp(String ts) {
    try { return ts.substring(11, 19); } catch (_) { return ts; }
  }
}
