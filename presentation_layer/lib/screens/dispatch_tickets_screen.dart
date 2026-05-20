import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/constants.dart';
import '../providers/crisis_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle_button.dart';

class DispatchTicketsScreen extends ConsumerStatefulWidget {
  const DispatchTicketsScreen({super.key});

  @override
  ConsumerState<DispatchTicketsScreen> createState() => _DispatchTicketsScreenState();
}

class _DispatchTicketsScreenState extends ConsumerState<DispatchTicketsScreen> {
  String _authorityFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final ticketsAsync = ref.watch(dispatchTicketsProvider);
    final authorityOptions = const ['ALL', 'POLICE', 'FIRE', 'PDMA', 'NDMA', 'HOSPITAL', 'NHA', 'RESCUE_1122'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dispatch Tickets'),
        actions: const [LanguageToggleButton()],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: authorityOptions.map((option) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(option),
                    selected: _authorityFilter == option,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() => _authorityFilter = option);
                      }
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: ticketsAsync.when(
              data: (tickets) {
                final filtered = tickets.where((ticket) {
                  if (_authorityFilter == 'ALL') return true;
                  final authority = (ticket['authority'] ?? ticket['authority_type'] ?? '').toString().toUpperCase();
                  return authority.contains(_authorityFilter);
                }).toList();

                if (filtered.isEmpty) {
                  return Center(child: Text(tr(ref, 'alerts_none')));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final ticket = filtered[index];
                    final authority = (ticket['authority'] ?? ticket['authority_type'] ?? 'UNKNOWN').toString().toUpperCase();
                    final priority = (ticket['priority'] ?? 'P3_STANDARD').toString().toUpperCase();
                    final location = (ticket['location'] ?? 'Unknown location').toString();
                    final status = (ticket['status'] ?? 'ISSUED').toString().toUpperCase();
                    final issuedAt = (ticket['issued_at'] ?? ticket['sent_at'] ?? '').toString();

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    authority,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                _priorityBadge(priority),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(location, style: const TextStyle(color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            _statusTimeline(status),
                            const SizedBox(height: 8),
                            Text(
                              'Status: $status',
                              style: TextStyle(color: _statusColor(status), fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              issuedAt.isEmpty ? '' : 'Issued: ${issuedAt.replaceFirst('T', ' ').substring(0, issuedAt.length > 19 ? 19 : issuedAt.length)}',
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
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

  Widget _priorityBadge(String priority) {
    final color = _priorityColor(priority);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: color),
      ),
      child: Text(
        priority.replaceAll('_', ' '),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 11),
      ),
    );
  }

  Widget _statusTimeline(String status) {
    const statuses = ['ISSUED', 'ACKNOWLEDGED', 'UNITS_DISPATCHED', 'ON_SCENE'];
    final activeIndex = statuses.indexOf(status);
    return Row(
      children: List.generate(statuses.length, (index) {
        final reached = activeIndex >= index;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: reached ? AppColors.statusAvailable : AppColors.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              if (index < statuses.length - 1)
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 2,
                    color: reached ? AppColors.statusAvailable : AppColors.textTertiary,
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }

  Color _priorityColor(String priority) {
    if (priority.startsWith('P1')) return AppColors.severityCritical;
    if (priority.startsWith('P2')) return AppColors.statusDispatched;
    return AppColors.severityMedium;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'ON_SCENE':
        return AppColors.statusAvailable;
      case 'UNITS_DISPATCHED':
        return AppColors.accentBlue;
      case 'ACKNOWLEDGED':
        return AppColors.statusDispatched;
      default:
        return AppColors.textSecondary;
    }
  }
}
