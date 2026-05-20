import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import '../providers/crisis_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle_button.dart';

class AgentLogsScreen extends ConsumerStatefulWidget {
  const AgentLogsScreen({super.key});

  @override
  ConsumerState<AgentLogsScreen> createState() => _AgentLogsScreenState();
}

class _AgentLogsScreenState extends ConsumerState<AgentLogsScreen> {
  String _selectedAgent = 'ALL';
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  Color _getAgentColor(String agentName) {
    if (agentName.toLowerCase().contains('sentinel')) return AppColors.agentSentinel;
    if (agentName.toLowerCase().contains('analyst')) return AppColors.agentAnalyst;
    if (agentName.toLowerCase().contains('commander')) return AppColors.agentCommander;
    if (agentName.toLowerCase().contains('dispatcher')) return AppColors.agentDispatcher;
    return AppColors.textSecondary;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logsAsync = ref.watch(agentLogsProvider);
    final isUrdu = ref.watch(languageProvider) == AppLanguage.urdu;
    final filterOptions = const ['ALL', 'SENTINEL', 'ANALYST', 'COMMANDER', 'DISPATCHER'];

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(ref, 'agent_logs_title')),
        actions: const [LanguageToggleButton()],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: filterOptions.map((filter) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(tr(ref, 'filter_${filter.toLowerCase()}')),
                    selected: _selectedAgent == filter,
                    onSelected: (selected) {
                      if (selected) setState(() => _selectedAgent = filter);
                    },
                    selectedColor: AppColors.accentBlue.withValues(alpha: 0.3),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: logsAsync.when(
              data: (logs) {
                final filtered = logs.where((l) {
                  if (_selectedAgent == 'ALL') return true;
                  return (l['agent_name'] as String? ?? '').toUpperCase().contains(_selectedAgent);
                }).toList();

                WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

                if (filtered.isEmpty) {
                  return Center(child: Text(tr(ref, 'no_agent_logs')));
                }

                return ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final log = filtered[index];
                    final agentName = log['agent_name'] ?? 'System';
                    final agentColor = _getAgentColor(agentName);
                    
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: AppColors.bgCard,
                        borderRadius: BorderRadius.circular(8),
                        border: Border(left: BorderSide(color: agentColor, width: 3)),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: agentColor.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  agentName,
                                  style: TextStyle(color: agentColor, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              Text(
                                log['timestamp']?.substring(11, 19) ?? '',
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(log['message'] ?? '', style: const TextStyle(fontSize: 14)),
                          if (log['data_ref'] != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              '${tr(ref, 'ref_label')}: ${log['data_ref']}',
                              style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppColors.accentCyan),
                            ),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1).shimmer(duration: 600.ms, color: agentColor.withValues(alpha: 0.3));
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}
