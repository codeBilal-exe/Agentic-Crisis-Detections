import 'package:flutter/material.dart';

class AppColors {
  // Background hierarchy
  static const Color bgDeep       = Color(0xFF080C14);  // Deepest background
  static const Color bgCard       = Color(0xFF0F1624);  // Card background
  static const Color bgElevated   = Color(0xFF16213A);  // Elevated elements
  static const Color borderSubtle = Color(0xFF1E2D4A);  // Borders

  // Brand & accent
  static const Color accentBlue   = Color(0xFF0A84FF);  // Primary accent
  static const Color accentCyan   = Color(0xFF00D4FF);  // Secondary accent

  // Severity colors — used consistently across ALL components
  static const Color severityCritical = Color(0xFFFF2D55);  // Red
  static const Color severityHigh     = Color(0xFFFF6B35);  // Orange-red
  static const Color severityMedium   = Color(0xFFFFCC00);  // Yellow
  static const Color severityLow      = Color(0xFF30D158);  // Green
  static const Color severityNone     = Color(0xFF636366);  // Gray

  // Status colors
  static const Color statusAvailable  = Color(0xFF30D158);
  static const Color statusDispatched = Color(0xFFFF9F0A);
  static const Color statusOnScene    = Color(0xFF0A84FF);

  // Text
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8E8E93);
  static const Color textTertiary  = Color(0xFF48484A);

  // Agent colors
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
}

class ApiEndpoints {
  static const String baseUrl            = 'http://10.0.2.2:8000'; // Android emulator localhost
  static const String triggerScenario    = '/api/simulation/trigger';
  static const String resetSimulation    = '/api/simulation/reset';
  static const String simulationStatus   = '/api/simulation/status';
  static const String listScenarios      = '/api/simulation/scenarios';
}
