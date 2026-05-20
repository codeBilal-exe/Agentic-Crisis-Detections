import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import '../models/crisis_model.dart';
import '../providers/language_provider.dart';
import 'severity_badge.dart';

class CrisisCard extends ConsumerWidget {
  final CrisisModel crisis;

  const CrisisCard({super.key, required this.crisis});

  @override
  Widget build(BuildContext context) {
    bool isHighOrCritical = crisis.severity == 'HIGH' || crisis.severity == 'CRITICAL';

    final confidenceLabel = tr(ref, 'confidence_label');
    Widget cardContent = Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(crisis.crisisTypeIcon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(crisis.crisisTypeLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(crisis.affectedAreaName, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
              SeverityBadge(severity: crisis.severity),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(confidenceLabel, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              const SizedBox(width: 8),
              Expanded(
                child: LinearProgressIndicator(
                  value: crisis.confidence,
                  color: crisis.severityColor,
                  backgroundColor: AppColors.bgElevated,
                ),
              ),
              const SizedBox(width: 8),
              Text('${(crisis.confidence * 100).toInt()}%', style: const TextStyle(fontSize: 12)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            crisis.reasoningSummary,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: AppColors.textSecondary, fontStyle: FontStyle.italic, fontSize: 12),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text(_formatTime(crisis.detectedAt), style: Theme.of(context).textTheme.labelSmall),
              const Spacer(),
              const Icon(Icons.people, size: 14, color: AppColors.textTertiary),
              const SizedBox(width: 4),
              Text('${crisis.estimatedPeopleAffected}', style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ],
      ),
    );

    Widget card = Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.borderSubtle),
      ),
      child: cardContent,
    );

    if (isHighOrCritical) {
      card = card.animate(onPlay: (c) => c.repeat()).shimmer(
        duration: 2.seconds,
        color: crisis.severityColor.withValues(alpha: 0.3),
      );
    }

    return GestureDetector(
      onTap: () => context.push('/crisis/${crisis.crisisId}'),
      child: card,
    );
  }

  String _formatTime(String timestamp) {
    if (timestamp.length >= 19) {
      return timestamp.substring(11, 19);
    }
    return timestamp;
  }
}
