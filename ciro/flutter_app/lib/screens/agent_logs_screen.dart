import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../providers/crisis_provider.dart';

class AgentLogsScreen extends ConsumerStatefulWidget {
  const AgentLogsScreen({super.key});
  @override
  ConsumerState<AgentLogsScreen> createState() => _AgentLogsScreenState();
}

class _AgentLogsScreenState extends ConsumerState<AgentLogsScreen> {
  String _filter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(agentLogsProvider);
    final systemAsync = ref.watch(systemStateProvider);

    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      appBar: AppBar(
        title: Row(children: [
          Text('AGENT PIPELINE LOGS', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(width: 10),
          systemAsync.whenOrNull(data: (state) {
            final mode = state['mode'] ?? 'monitoring';
            if (mode == 'crisis_active') return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(color: AppColors.severityCritical.withOpacity(0.2), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.severityCritical)),
              child: Text('PIPELINE ACTIVE', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: AppColors.severityCritical, fontWeight: FontWeight.w600)));
            return null;
          }) ?? const SizedBox(),
        ]),
      ),
      body: Column(children: [
        // Filter tabs
        Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(scrollDirection: Axis.horizontal,
            child: Row(children: ['ALL', 'Sentinel', 'Analyst', 'Commander', 'Dispatcher'].map((agent) {
              final isActive = _filter == agent;
              final color = _getAgentColor(agent);
              return GestureDetector(
                onTap: () => setState(() => _filter = agent),
                child: Container(margin: const EdgeInsets.only(right: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: isActive ? color.withOpacity(0.2) : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isActive ? color : AppColors.borderSubtle)),
                  child: Text(agent, style: GoogleFonts.inter(fontSize: 12, color: isActive ? color : AppColors.textSecondary, fontWeight: isActive ? FontWeight.w600 : FontWeight.w400)),
                ),
              );
            }).toList()),
          ),
        ),
        // Log entries
        Expanded(child: logsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentBlue)),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (logs) {
            final filtered = _filter == 'ALL' ? logs : logs.where((l) => l['agent'] == _filter).toList();
            if (filtered.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.terminal, size: 64, color: AppColors.textTertiary),
              const SizedBox(height: 12),
              Text('No Agent Logs', style: GoogleFonts.inter(fontSize: 16, color: AppColors.textSecondary)),
              const SizedBox(height: 4),
              Text('Run the Antigravity pipeline to generate logs', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textTertiary)),
            ]));
            return ListView.builder(
              padding: const EdgeInsets.all(16), itemCount: filtered.length,
              itemBuilder: (ctx, i) => _buildLogEntry(filtered[i]).animate().fadeIn(delay: (i * 80).ms, duration: 250.ms),
            );
          },
        )),
      ]),
    );
  }

  Widget _buildLogEntry(Map<String, dynamic> log) {
    final agent = log['agent'] ?? 'Unknown';
    final color = _getAgentColor(agent);
    final message = log['message'] ?? '';
    final timestamp = log['timestamp'] ?? '';
    final dataRef = log['data_ref'] ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 3)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
            child: Text(agent.toUpperCase(), style: GoogleFonts.jetBrainsMono(fontSize: 10, color: color, fontWeight: FontWeight.w700))),
          const Spacer(),
          Text(_formatTimestamp(timestamp), style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppColors.textTertiary)),
        ]),
        const SizedBox(height: 8),
        Text(message, style: GoogleFonts.inter(fontSize: 13, color: AppColors.textPrimary, height: 1.4)),
        if (dataRef.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text('ref: $dataRef', style: GoogleFonts.jetBrainsMono(fontSize: 9, color: AppColors.textTertiary)),
        ],
      ]),
    );
  }

  Color _getAgentColor(String agent) {
    switch (agent) {
      case 'Sentinel': return AppColors.agentSentinel;
      case 'Analyst': return AppColors.agentAnalyst;
      case 'Commander': return AppColors.agentCommander;
      case 'Dispatcher': return AppColors.agentDispatcher;
      default: return AppColors.accentBlue;
    }
  }

  String _formatTimestamp(String ts) {
    try { return ts.substring(11, 19); } catch (_) { return ts; }
  }
}
