import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:async';
import '../core/constants.dart';
import '../providers/crisis_provider.dart';

class UnitTrackerScreen extends ConsumerWidget {
  const UnitTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(unitsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('RESPONSE UNITS')),
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
                        Text('Destination: ${u.destination}', style: Theme.of(context).textTheme.bodyMedium),
                        const SizedBox(height: 8),
                        if (u.etaMinutes != null) UnitEtaCountdown(etaMinutes: u.etaMinutes!),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error loading units: $e')),
      ),
    );
  }
}

class UnitEtaCountdown extends StatefulWidget {
  final int etaMinutes;
  const UnitEtaCountdown({super.key, required this.etaMinutes});

  @override
  State<UnitEtaCountdown> createState() => _UnitEtaCountdownState();
}

class _UnitEtaCountdownState extends State<UnitEtaCountdown> {
  int _elapsedSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int totalSeconds = widget.etaMinutes * 60;
    int remainingSeconds = totalSeconds - _elapsedSeconds;

    if (remainingSeconds <= 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.severityLow.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.severityLow),
        ),
        child: const Text('ARRIVING', style: TextStyle(color: AppColors.severityLow, fontWeight: FontWeight.bold)),
      ).animate(onPlay: (c) => c.repeat(reverse: true)).fade(begin: 0.5, end: 1.0);
    }

    int m = remainingSeconds ~/ 60;
    int s = remainingSeconds % 60;
    double progress = _elapsedSeconds / totalSeconds;
    if (progress > 1.0) progress = 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('ETA', style: TextStyle(fontWeight: FontWeight.bold)),
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
