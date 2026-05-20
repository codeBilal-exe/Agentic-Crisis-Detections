import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AppColors {
  static const Color bgDeep       = Color(0xFF080C14);
  static const Color bgCard       = Color(0xFF0F1624);
  static const Color bgElevated   = Color(0xFF16213A);
  static const Color borderSubtle = Color(0xFF1E2D4A);
  static const Color accentBlue   = Color(0xFF0A84FF);
  static const Color accentCyan   = Color(0xFF00D4FF);
  static const Color severityCritical = Color(0xFFFF2D55);
  static const Color severityHigh     = Color(0xFFFF6B35);
  static const Color severityMedium   = Color(0xFFFFCC00);
  static const Color severityLow      = Color(0xFF30D158);
  static const Color severityNone     = Color(0xFF636366);
  static const Color statusAvailable  = Color(0xFF30D158);
  static const Color statusDispatched = Color(0xFFFF9F0A);
  static const Color statusOnScene    = Color(0xFF0A84FF);
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary  = Color(0xFF48484A);
  static const Color agentSentinel   = Color(0xFF00D4FF);
  static const Color agentAnalyst    = Color(0xFF9B59B6);
  static const Color agentCommander  = Color(0xFFFF9F0A);
  static const Color agentDispatcher = Color(0xFF30D158);
}

class AppStrings {
  static const String appName    = 'CIRO';
  static const String appTagline = 'Crisis Intelligence & Response Orchestrator';
  static const String orgName    = 'National Emergency Response System — Pakistan';
}

class FirebasePaths {
  static const String systemState    = 'system_state';
  static const String activeCrises   = 'active_crises';
  static const String units          = 'units';
  static const String alerts         = 'alerts';
  static const String activeReroutes = 'routes/active_reroutes';
  static const String agentLogs      = 'agent_logs';
  static const String outcomeMetrics = 'outcome_metrics';
  static const String signalFeed     = 'signal_feed/recent_signals';
  static const String escalationLog  = 'escalation_log';
  static const String signalStats    = 'signal_feed/statistics';
  static const String coordinationMessages = 'coordination_messages';
}

class ApiEndpoints {
  static String get baseUrl => kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000';
  static const String triggerScenario    = '/api/simulation/trigger';
  static const String resetSimulation    = '/api/simulation/reset';
  static const String simulationStatus   = '/api/simulation/status';
  static const String listScenarios      = '/api/simulation/scenarios';
}
