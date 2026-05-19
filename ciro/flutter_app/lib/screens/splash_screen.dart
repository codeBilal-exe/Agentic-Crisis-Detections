import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _statusText = 'INITIALIZING SYSTEMS...';
  Color _statusColor = AppColors.textTertiary;

  @override
  void initState() {
    super.initState();
    _initSequence();
  }

  Future<void> _initSequence() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() { _statusText = 'CONNECTING TO FIREBASE...'; _statusColor = AppColors.accentCyan; });
    await Future.delayed(const Duration(milliseconds: 1200));
    if (mounted) setState(() { _statusText = 'SYSTEMS ONLINE'; _statusColor = AppColors.statusAvailable; });
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 3),
            Text('CIRO', style: GoogleFonts.spaceGrotesk(fontSize: 72, fontWeight: FontWeight.w800, color: AppColors.accentBlue, letterSpacing: 8))
                .animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: 0.3, end: 0),
            const SizedBox(height: 12),
            Text(AppStrings.appTagline, style: GoogleFonts.inter(fontSize: 14, color: AppColors.textSecondary, letterSpacing: 1.5), textAlign: TextAlign.center)
                .animate().fadeIn(delay: 700.ms, duration: 500.ms),
            const SizedBox(height: 8),
            Text('🇵🇰 ${AppStrings.orgName}', style: GoogleFonts.inter(fontSize: 12, color: AppColors.accentCyan, fontWeight: FontWeight.w500), textAlign: TextAlign.center)
                .animate().fadeIn(delay: 900.ms, duration: 500.ms),
            const SizedBox(height: 48),
            Container(width: 80, height: 80,
              decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: AppColors.accentBlue.withOpacity(0.3), width: 2)),
              child: const Center(child: Icon(Icons.radar, color: AppColors.accentBlue, size: 32)),
            ).animate(onPlay: (c) => c.repeat()).scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 1200.ms).then().scale(begin: const Offset(1.1, 1.1), end: const Offset(0.9, 0.9), duration: 1200.ms),
            const SizedBox(height: 48),
            Text(_statusText, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: _statusColor, letterSpacing: 2)).animate().fadeIn(delay: 1200.ms),
            const Spacer(flex: 2),
            Text('v1.0 | HACKATHON BUILD', style: GoogleFonts.jetBrainsMono(fontSize: 10, color: AppColors.textTertiary)).animate().fadeIn(delay: 1500.ms),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
