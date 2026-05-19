import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../providers/crisis_provider.dart';
import '../models/unit_model.dart';

class UnitTrackerScreen extends ConsumerWidget {
  const UnitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(unitsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: Row(children: [
          Text('RESCUE UNITS', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          unitsAsync.whenOrNull(data: (units) {
            final available = units.where((u) => u.status == 'available').length;
            return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.statusAvailable, borderRadius: BorderRadius.circular(10)),
              child: Text('$available available', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white)));
          }) ?? const SizedBox(),
        ]),
      ),
      body: unitsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (units) {
          final available = units.where((u) => u.status == 'available').length;
          final deployed = units.where((u) => u.status == 'dispatched' || u.status == 'on_scene').length;
          final standby = units.where((u) => u.status == 'standby').length;

          return Column(children: [
            // Summary bar
            Container(padding: const EdgeInsets.all(12), margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderSubtle)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _statPill('$available', 'Available', AppColors.statusAvailable),
                _statPill('$deployed', 'Deployed', AppColors.statusDispatched),
                _statPill('$standby', 'Standby', AppColors.severityNone),
              ]),
            ),
            // Unit list
            Expanded(child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: units.length,
              itemBuilder: (ctx, i) => _buildUnitCard(units[i]).animate().fadeIn(delay: (i * 100).ms, duration: 300.ms).slideX(begin: 0.05, end: 0),
            )),
          ]);
        },
      ),
    );
  }

  Widget _statPill(String value, String label, Color color) {
    return Column(children: [
      Text(value, style: GoogleFonts.spaceGrotesk(fontSize: 24, fontWeight: FontWeight.w700, color: color)),
      Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondary)),
    ]);
  }

  Widget _buildUnitCard(UnitModel unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: unit.status == 'dispatched' ? AppColors.statusDispatched.withOpacity(0.4) : AppColors.borderSubtle)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(unit.typeIcon, style: const TextStyle(fontSize: 36)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(unit.name, style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
            Text('ID: ${unit.unitId}', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppColors.textTertiary)),
          ])),
          Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: unit.statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: unit.statusColor)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: unit.statusColor)),
              const SizedBox(width: 6),
              Text(unit.statusLabel, style: GoogleFonts.jetBrainsMono(fontSize: 10, color: unit.statusColor, fontWeight: FontWeight.w600)),
            ]),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          _infoChip('Type: ${unit.typeLabel}'),
          if (unit.status == 'dispatched' || unit.status == 'on_scene') ...[
            const SizedBox(width: 8),
            _infoChip(unit.unitId.contains('1122') ? 'RESCUE 1122' : 'PDMA', color: AppColors.accentCyan),
          ],
        ]),
        if (unit.destination != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.navigation, size: 14, color: AppColors.statusDispatched),
            const SizedBox(width: 6),
            Expanded(child: Text('Destination: ${unit.destination}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary))),
          ]),
        ],
        if (unit.etaMinutes != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.timer, size: 14, color: AppColors.accentCyan),
            const SizedBox(width: 6),
            Text('ETA: ${unit.etaMinutes} minutes', style: GoogleFonts.jetBrainsMono(fontSize: 12, color: AppColors.accentCyan, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 6),
          ClipRRect(borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(value: 0.6, backgroundColor: AppColors.borderSubtle, valueColor: const AlwaysStoppedAnimation(AppColors.statusDispatched), minHeight: 4)),
        ],
      ]),
    );
  }

  Widget _infoChip(String text, {Color color = AppColors.textSecondary}) {
    return Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.3))),
      child: Text(text, style: GoogleFonts.inter(fontSize: 10, color: color, fontWeight: FontWeight.w500)));
  }
}
