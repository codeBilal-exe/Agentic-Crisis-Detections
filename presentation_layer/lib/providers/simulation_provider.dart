import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class SimulationState {
  final String mode;
  final bool isLoading;
  final List<Map<String, dynamic>> scenarios;
  final String? activeScenario;
  final String? error;

  const SimulationState({
    this.mode = 'monitoring',
    this.isLoading = false,
    this.scenarios = const [],
    this.activeScenario,
    this.error,
  });

  SimulationState copyWith({
    String? mode,
    bool? isLoading,
    List<Map<String, dynamic>>? scenarios,
    String? activeScenario,
    String? error,
  }) {
    return SimulationState(
      mode: mode ?? this.mode,
      isLoading: isLoading ?? this.isLoading,
      scenarios: scenarios ?? this.scenarios,
      activeScenario: activeScenario ?? this.activeScenario,
      error: error ?? this.error,
    );
  }
}

class SimulationNotifier extends StateNotifier<SimulationState> {
  SimulationNotifier() : super(const SimulationState());

  Future<void> loadScenarios() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.get(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.listScenarios}'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final scenarios = List<Map<String, dynamic>>.from(data['scenarios'] ?? []);
        state = state.copyWith(scenarios: scenarios, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to load scenarios');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> triggerScenario(String scenarioName) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.triggerScenario}$scenarioName'),
      );
      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          mode: 'crisis_active',
          activeScenario: scenarioName,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to trigger scenario');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> resetSimulation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.resetSimulation}'),
      );
      if (response.statusCode == 200) {
        state = state.copyWith(
          isLoading: false,
          mode: 'monitoring',
          activeScenario: null,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: 'Failed to reset');
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }
}

final simulationProvider = StateNotifierProvider<SimulationNotifier, SimulationState>(
  (ref) => SimulationNotifier(),
);
