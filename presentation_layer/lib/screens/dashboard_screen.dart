import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import '../core/constants.dart';
import '../providers/crisis_provider.dart';
import '../models/crisis_model.dart';
import '../models/unit_model.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crisesAsync = ref.watch(activeCrisesProvider);
    final unitsAsync = ref.watch(unitsProvider);
    final systemAsync = ref.watch(systemStateProvider);
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: Row(children: [
          Text('CIRO', style: GoogleFonts.spaceGrotesk(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.accentBlue, letterSpacing: 3)),
          const SizedBox(width: 12),
          systemAsync.when(
            data: (state) {
              final mode = state['mode'] ?? 'monitoring';
              final isActive = mode == 'crisis_active' || mode == 'simulation';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.severityCritical.withOpacity(0.2) : AppColors.accentBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: isActive ? AppColors.severityCritical : AppColors.accentBlue, width: 1),
                ),
                child: Text(mode.toUpperCase().replaceAll('_', ' '),
                  style: GoogleFonts.jetBrainsMono(fontSize: 10, color: isActive ? AppColors.severityCritical : AppColors.accentBlue, fontWeight: FontWeight.w600)),
              );
            },
            loading: () => const SizedBox(),
            error: (_, __) => const SizedBox(),
          ),
        ]),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // System Status Bar
          systemAsync.when(
            data: (state) => _buildStatusBar(state),
            loading: () => _shimmerBox(height: 48),
            error: (_, __) => _buildStatusBar({'mode': 'offline'}),
          ),
          const SizedBox(height: 20),

          // Active Crises Section
          Row(children: [
            Text('ACTIVE CRISES', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(width: 8),
            crisesAsync.when(
              data: (crises) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(color: crises.isEmpty ? AppColors.statusAvailable : AppColors.severityCritical, borderRadius: BorderRadius.circular(10)),
                child: Text('${crises.length}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white)),
              ),
              loading: () => const SizedBox(),
              error: (_, __) => const SizedBox(),
            ),
          ]),
          const SizedBox(height: 12),
          crisesAsync.when(
            data: (crises) => crises.isEmpty
                ? _buildAllClear()
                : Column(children: crises.map((c) => _buildCrisisCard(context, c)).toList()),
            loading: () => _shimmerBox(height: 160),
            error: (e, _) => Text('Error: $e', style: const TextStyle(color: AppColors.severityCritical)),
          ),
          const SizedBox(height: 24),

          // Unit Status Grid
          Text('RESCUE UNITS', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          unitsAsync.when(
            data: (units) => GridView.count(
              crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.5,
              children: units.map((u) => _buildUnitMiniCard(context, u)).toList(),
            ),
            loading: () => _shimmerBox(height: 200),
            error: (e, _) => Text('Error: $e'),
          ),
          const SizedBox(height: 24),

          // Quick Actions Row
          Text('QUICK ACTIONS', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(children: [
              _buildQuickAction(context, '🗺', 'Live Map', '/map'),
              _buildQuickAction(context, '📡', 'Alerts', '/alerts'),
              _buildQuickAction(context, '📋', 'Agent Logs', '/agent-logs'),
              _buildQuickAction(context, '🚐', 'Units', '/units'),
            ]),
          ),
          const SizedBox(height: 80),
        ]),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.severityCritical,
        icon: const Icon(Icons.bolt, color: Colors.white),
        label: Text('TRIGGER', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700, color: Colors.white)),
        onPressed: () => _showScenarioSheet(context),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.bgCard,
        selectedItemColor: AppColors.accentBlue,
        unselectedItemColor: AppColors.textTertiary,
        currentIndex: 0,
        items: [
          const BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: 'Dashboard'),
          const BottomNavigationBarItem(icon: Icon(Icons.map), label: 'Map'),
          const BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Units'),
          BottomNavigationBarItem(
            icon: Stack(children: [
              const Icon(Icons.notifications),
              alertsAsync.when(
                data: (alerts) {
                  final unack = alerts.where((a) => !a.acknowledged).length;
                  return unack > 0 ? Positioned(right: 0, child: Container(
                    padding: const EdgeInsets.all(2), decoration: const BoxDecoration(color: AppColors.severityCritical, shape: BoxShape.circle),
                    child: Text('$unack', style: const TextStyle(fontSize: 8, color: Colors.white)),
                  )) : const SizedBox();
                },
                loading: () => const SizedBox(),
                error: (_, __) => const SizedBox(),
              ),
            ]),
            label: 'Alerts',
          ),
          const BottomNavigationBarItem(icon: Icon(Icons.terminal), label: 'Logs'),
        ],
        onTap: (i) {
          final routes = ['/dashboard', '/map', '/units', '/alerts', '/agent-logs'];
          if (i > 0) context.go(routes[i]);
        },
      ),
    );
  }

  Widget _buildStatusBar(Map<String, dynamic> state) {
    final mode = state['mode'] ?? 'monitoring';
    final isActive = mode == 'crisis_active' || mode == 'simulation';
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: isActive
            ? [AppColors.severityCritical.withOpacity(0.2), AppColors.severityCritical.withOpacity(0.05)]
            : [AppColors.accentBlue.withOpacity(0.15), AppColors.accentBlue.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isActive ? AppColors.severityCritical.withOpacity(0.5) : AppColors.accentBlue.withOpacity(0.3)),
      ),
      child: Row(children: [
        Icon(isActive ? Icons.warning_rounded : Icons.shield, color: isActive ? AppColors.severityCritical : AppColors.accentBlue, size: 20),
        const SizedBox(width: 10),
        Text(isActive ? 'CRISIS ACTIVE — RESPONSE IN PROGRESS' : 'ALL SYSTEMS MONITORING — NO ACTIVE THREATS',
          style: GoogleFonts.jetBrainsMono(fontSize: 11, color: isActive ? AppColors.severityCritical : AppColors.accentBlue, fontWeight: FontWeight.w600)),
      ]),
    );
  }

  Widget _buildAllClear() {
    return Container(
      width: double.infinity, padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.statusAvailable.withOpacity(0.3))),
      child: Column(children: [
        const Icon(Icons.check_circle, color: AppColors.statusAvailable, size: 48),
        const SizedBox(height: 12),
        Text('All Clear — No Active Crises', style: GoogleFonts.inter(fontSize: 16, color: AppColors.statusAvailable, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('System is monitoring signals in real time', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    );
  }

  Widget _buildCrisisCard(BuildContext context, CrisisModel crisis) {
    return GestureDetector(
      onTap: () => context.go('/crisis/${crisis.crisisId}'),
      child: Container(
        width: double.infinity, margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [crisis.severityColor.withOpacity(0.08), AppColors.bgCard]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: crisis.severityColor.withOpacity(0.4), width: 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Text(crisis.crisisTypeIcon, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(child: Text(crisis.crisisTypeLabel, style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: crisis.severityColor, borderRadius: BorderRadius.circular(8)),
              child: Text(crisis.severity, style: GoogleFonts.jetBrainsMono(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ]),
          const SizedBox(height: 10),
          _infoRow(Icons.location_on, crisis.affectedAreaName),
          _infoRow(Icons.people, '~${crisis.estimatedPeopleAffected} people at risk'),
          if (crisis.roadsBlocked.isNotEmpty)
            _infoRow(Icons.block, crisis.roadsBlocked.join(', ')),
          const SizedBox(height: 8),
          // Confidence bar
          Row(children: [
            Text('Confidence: ', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary)),
            Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: crisis.confidence, backgroundColor: AppColors.borderSubtle, valueColor: AlwaysStoppedAnimation(crisis.severityColor), minHeight: 6))),
            const SizedBox(width: 8),
            Text('${(crisis.confidence * 100).toInt()}%', style: GoogleFonts.jetBrainsMono(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          ]),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: AppColors.bgElevated, borderRadius: BorderRadius.circular(8), border: Border(left: BorderSide(color: AppColors.accentCyan, width: 3))),
            child: Text('🤖 ${crisis.reasoningSummary}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary, fontStyle: FontStyle.italic), maxLines: 3, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(height: 8),
          Align(alignment: Alignment.centerRight,
            child: Text('VIEW DETAILS →', style: GoogleFonts.spaceGrotesk(fontSize: 12, color: AppColors.accentBlue, fontWeight: FontWeight.w700)),
          ),
        ]),
      ).animate().fadeIn(duration: 400.ms).slideX(begin: 0.05, end: 0),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondary), overflow: TextOverflow.ellipsis)),
      ]));
  }

  Widget _buildUnitMiniCard(BuildContext context, UnitModel unit) {
    return GestureDetector(
      onTap: () => context.go('/units'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderSubtle)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(unit.typeIcon, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 4),
          Text(unit.name, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textPrimary, fontWeight: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Row(children: [
            Container(width: 8, height: 8, decoration: BoxDecoration(shape: BoxShape.circle, color: unit.statusColor)),
            const SizedBox(width: 6),
            Text(unit.statusLabel, style: GoogleFonts.jetBrainsMono(fontSize: 9, color: unit.statusColor, fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
    );
  }

  Widget _buildQuickAction(BuildContext context, String emoji, String label, String route) {
    return GestureDetector(
      onTap: () => context.go(route),
      child: Container(
        margin: const EdgeInsets.only(right: 10), padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.borderSubtle)),
        child: Row(children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(label, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }

  Widget _shimmerBox({double height = 100}) {
    return Shimmer.fromColors(baseColor: AppColors.bgCard, highlightColor: AppColors.bgElevated,
      child: Container(height: height, width: double.infinity, decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12))));
  }

  void _showScenarioSheet(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.listScenarios}'));
      if (response.statusCode != 200) throw Exception('API error');
      final data = jsonDecode(response.body);
      final scenarios = List<Map<String, dynamic>>.from(data['scenarios'] ?? []);
      if (!context.mounted) return;
      showModalBottomSheet(context: context, backgroundColor: AppColors.bgCard, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (ctx) => Padding(padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('TRIGGER SCENARIO', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
            const SizedBox(height: 16),
            ...scenarios.map((s) => ListTile(
              title: Text(s['scenario_name'] ?? '', style: const TextStyle(color: AppColors.textPrimary)),
              subtitle: Text(s['description'] ?? '', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              trailing: const Icon(Icons.play_arrow, color: AppColors.accentBlue),
              onTap: () async {
                Navigator.pop(ctx);
                await http.post(Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.triggerScenario}/${s['scenario_id']}'));
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Scenario "${s['scenario_name']}" activated!'), backgroundColor: AppColors.accentBlue));
              },
            )),
            const SizedBox(height: 8),
            SizedBox(width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: AppColors.severityCritical, side: const BorderSide(color: AppColors.severityCritical)),
                icon: const Icon(Icons.refresh), label: const Text('RESET SYSTEM'),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await http.post(Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.resetSimulation}'));
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('System reset to monitoring baseline'), backgroundColor: AppColors.statusAvailable));
                },
              ),
            ),
          ]),
        ),
      );
    } catch (e) {
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cannot reach server: $e'), backgroundColor: AppColors.severityCritical));
    }
  }
}
