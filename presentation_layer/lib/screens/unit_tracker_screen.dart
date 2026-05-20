import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../core/constants.dart';
import '../providers/crisis_provider.dart';
import '../providers/language_provider.dart';
import '../widgets/language_toggle_button.dart';

class UnitTrackerScreen extends ConsumerWidget {
  const UnitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(unitsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(tr(ref, 'response_units_title')),
        actions: const [LanguageToggleButton()],
      ),
      body: unitsAsync.when(
        data: (units) {
          if (units.isEmpty) {
            return const Center(child: Text('No units available.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: units.length,
            itemBuilder: (context, index) {
              final u = units[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(u.typeIcon, style: const TextStyle(fontSize: 24)),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(u.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(u.typeLabel, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: u.statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: u.statusColor),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 8, height: 8,
                                  decoration: BoxDecoration(color: u.statusColor, shape: BoxShape.circle),
                                ).animate(onPlay: (c) {
                                  if (u.status == 'dispatched') c.repeat();
                                }).scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 800.ms),
                                const SizedBox(width: 6),
                                Text(
                                  u.statusLabel,
                                  style: TextStyle(color: u.statusColor, fontWeight: FontWeight.bold, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (u.status == 'dispatched' && u.destination != null) ...[
                        const SizedBox(height: 16),
                        Text('${tr(ref, 'destination_label')}: ${u.destination}', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        if (u.etaMinutes != null) UnitEtaCountdown(key: ValueKey(u.unitId), etaMinutes: u.etaMinutes!),
                      ],
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
    );
  }
}

class UnitEtaCountdown extends ConsumerStatefulWidget {
  final int etaMinutes;
  const UnitEtaCountdown({super.key, required this.etaMinutes});

  @override
  ConsumerState<UnitEtaCountdown> createState() => _UnitEtaCountdownState();
}

class _UnitEtaCountdownState extends ConsumerState<UnitEtaCountdown> {
  late int _remainingSeconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.etaMinutes * 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds = (_remainingSeconds - 1).clamp(0, widget.etaMinutes * 60);
      });
    });
  }

  @override
  void didUpdateWidget(covariant UnitEtaCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newTotal = widget.etaMinutes * 60;
    if (widget.etaMinutes != oldWidget.etaMinutes || _remainingSeconds > newTotal) {
      setState(() {
        _remainingSeconds = newTotal;
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remainingSeconds <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.severityLow.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.severityLow),
        ),
        child: Text(tr(ref, 'arriving_text'), style: const TextStyle(color: AppColors.severityLow, fontWeight: FontWeight.bold)),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.5, end: 1.0);
    }

    final int m = _remainingSeconds ~/ 60;
    final int s = _remainingSeconds % 60;
    final int totalSeconds = widget.etaMinutes * 60;
    final double progress = totalSeconds > 0 ? (1 - _remainingSeconds / totalSeconds) : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(tr(ref, 'eta_label'), style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${m}m ${s}s', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.statusDispatched)),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: progress,
          color: AppColors.statusDispatched,
          backgroundColor: AppColors.bgElevated,
        ),
      ],
    );
  }
}
