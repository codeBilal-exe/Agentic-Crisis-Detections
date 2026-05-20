import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import '../providers/crisis_provider.dart';

class AgentPipelineIndicator extends ConsumerWidget {
  const AgentPipelineIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final systemStateAsync = ref.watch(systemStateProvider);
    
    return systemStateAsync.when(
      data: (state) {
        // Here we could extract active/completed agents from the state if available
        // For demonstration, we'll assume a dummy logic based on state['mode']
        return _buildPipeline(context, state);
      },
      loading: () => _buildPipeline(context, {}),
      error: (_, __) => _buildPipeline(context, {}),
    );
  }

  Widget _buildPipeline(BuildContext context, Map<String, dynamic> state) {
    // Agents definition
    final agents = [
      {'name': 'Sentinel', 'color': AppColors.agentSentinel},
      {'name': 'Analyst', 'color': AppColors.agentAnalyst},
      {'name': 'Commander', 'color': AppColors.agentCommander},
      {'name': 'Dispatcher', 'color': AppColors.agentDispatcher},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(agents.length * 2 - 1, (index) {
        if (index % 2 != 0) {
          // Connector line
          return Container(
            height: 2,
            width: 20,
            color: AppColors.borderSubtle,
          );
        }
        
        int agentIndex = index ~/ 2;
        var agent = agents[agentIndex];
        Color color = agent['color'] as Color;
        
        // Mock status logic for visualization
        bool isCompleted = false;
        bool isActive = false;
        if (state['mode'] == 'crisis_active') {
          // If crisis is active, make one of them active for demo
          isActive = agentIndex == 1; // Analyst active
          isCompleted = agentIndex < 1; // Sentinel completed
        }

        Widget circle = Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
          ),
          child: isCompleted ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
        );

        if (isActive) {
          circle = circle.animate(onPlay: (c) => c.repeat(reverse: true)).scale(begin: const Offset(1, 1), end: const Offset(1.1, 1.1));
        }

        return Column(
          children: [
            circle,
            const SizedBox(height: 4),
            Text(
              agent['name'] as String,
              style: TextStyle(color: color, fontSize: 9, fontWeight: FontWeight.bold),
            ),
          ],
        );
      }),
    );
  }
}
