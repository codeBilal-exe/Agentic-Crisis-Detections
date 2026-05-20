import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';
import '../providers/crisis_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle_button.dart';

class AlertFeedScreen extends ConsumerStatefulWidget {
  const AlertFeedScreen({super.key});

  @override
  ConsumerState<AlertFeedScreen> createState() => _AlertFeedScreenState();
}

class _AlertFeedScreenState extends ConsumerState<AlertFeedScreen> {
  String _selectedFilter = 'ALL';

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsProvider);
    final isUrdu = ref.watch(languageProvider) == AppLanguage.urdu;
    final filterOptions = const ['ALL', 'CRITICAL', 'HIGH', 'MEDIUM'];

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(ref, 'alert_feed_title')),
        actions: const [LanguageToggleButton()],
      ),
      body: Directionality(
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: filterOptions.map((filter) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(tr(ref, 'filter_${filter.toLowerCase()}')),
                      selected: _selectedFilter == filter,
                      onSelected: (selected) {
                        if (selected) setState(() => _selectedFilter = filter);
                      },
                      selectedColor: AppColors.accentBlue.withValues(alpha: 0.3),
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: alertsAsync.when(
              data: (alerts) {
                final filtered = alerts.where((a) {
                  if (_selectedFilter == 'ALL') return true;
                  return a.severity.toUpperCase() == _selectedFilter;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(child: Text(tr(ref, 'alerts_none')));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final a = filtered[index];
                    Color sevColor;
                    switch (a.severity.toUpperCase()) {
                      case 'CRITICAL': sevColor = AppColors.severityCritical; break;
                      case 'HIGH': sevColor = AppColors.severityHigh; break;
                      case 'MEDIUM': sevColor = AppColors.severityMedium; break;
                      default: sevColor = AppColors.severityLow;
                    }

                    final alertBody = isUrdu && a.urduBody.isNotEmpty ? a.urduBody : a.body;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: AppColors.borderSubtle),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: sevColor, width: 4)),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '⚠️ ${a.title}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            if (isUrdu)
                              Directionality(
                                textDirection: TextDirection.rtl,
                                child: Text(
                                  alertBody,
                                  style: GoogleFonts.notoNastaliqUrdu(
                                    fontSize: 15,
                                    height: 1.8,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              )
                            else
                              Text(alertBody, style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              children: a.channelsSent.map((c) => Chip(
                                label: Text(c, style: const TextStyle(fontSize: 10)),
                                padding: EdgeInsets.zero,
                                backgroundColor: AppColors.bgElevated,
                              )).toList(),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                a.acknowledged
                                    ? Text(tr(ref, 'acknowledged'), style: const TextStyle(color: AppColors.severityLow, fontWeight: FontWeight.bold))
                                    : ElevatedButton(
                                        onPressed: () {
                                          ref.read(firebaseServiceProvider).acknowledgeAlert(a.alertId);
                                        },
                                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.bgElevated),
                                        child: Text(tr(ref, 'acknowledge')),
                                      ),
                                Text(
                                  a.createdAt.substring(0, 16).replaceFirst('T', ' '),
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, st) => Center(child: Text(tr(ref, 'loading_error'))),
            ),
          ),
        ],
      ),
    );
  }
}
