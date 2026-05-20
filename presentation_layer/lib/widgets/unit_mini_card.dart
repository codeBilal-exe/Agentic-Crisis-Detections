import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import '../models/unit_model.dart';

class UnitMiniCard extends StatelessWidget {
  final UnitModel unit;

  const UnitMiniCard({super.key, required this.unit});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/units'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgCard,
          border: Border.all(color: AppColors.borderSubtle),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(unit.typeIcon, style: const TextStyle(fontSize: 28)),
            const Spacer(),
            Text(
              unit.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: BoxDecoration(color: unit.statusColor, shape: BoxShape.circle),
                ).animate(onPlay: (c) {
                  if (unit.status == 'dispatched') c.repeat();
                }).scale(begin: const Offset(1, 1), end: const Offset(1.3, 1.3), duration: 800.ms),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    unit.statusLabel,
                    style: TextStyle(color: unit.statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
