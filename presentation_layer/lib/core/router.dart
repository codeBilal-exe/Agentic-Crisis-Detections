import 'package:go_router/go_router.dart';
import '../screens/splash_screen.dart';
import '../screens/dashboard_screen.dart';
import '../screens/crisis_detail_screen.dart';
import '../screens/map_screen.dart';
import '../screens/unit_tracker_screen.dart';
import '../screens/alert_feed_screen.dart';
import '../screens/agent_logs_screen.dart';
import '../screens/demo_control_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/splash',
  routes: [
    GoRoute(path: '/splash',        builder: (c, s) => const SplashScreen()),
    GoRoute(path: '/dashboard',     builder: (c, s) => const DashboardScreen()),
    GoRoute(
      path: '/crisis/:id',
      builder: (c, s) => CrisisDetailScreen(crisisId: s.pathParameters['id']!),
    ),
    GoRoute(path: '/map',           builder: (c, s) => const MapScreen()),
    GoRoute(path: '/units',         builder: (c, s) => const UnitTrackerScreen()),
    GoRoute(path: '/alerts',        builder: (c, s) => const AlertFeedScreen()),
    GoRoute(path: '/agent-logs',    builder: (c, s) => const AgentLogsScreen()),
    GoRoute(path: '/demo-control',  builder: (c, s) => const DemoControlScreen()),
  ],
);
