import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../core/constants.dart';
import '../providers/language_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _isConnected = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _checkConnectionAndNavigate();
  }

  Future<void> _checkConnectionAndNavigate() async {
    try {
      // Check Firebase connection
      await FirebaseDatabase.instance.ref('.info/connected').get();
      setState(() => _isConnected = true);
    } catch (e) {
      setState(() => _hasError = true);
    }

    // Auto-navigate after 3.5 seconds
    Future.delayed(const Duration(milliseconds: 3500), () {
      if (mounted) {
        context.go('/dashboard');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDeep,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            GestureDetector(
              onLongPress: () => context.go('/demo-control'),
              child: Text(
                'CIRO',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.5, end: 0, duration: 800.ms),
            ),
            const SizedBox(height: 8),
            Text(
              tr(ref, 'tagline'),
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 800.ms),
            const SizedBox(height: 32),
            if (_hasError)
              Text(
                tr(ref, 'connection_error'),
                style: GoogleFonts.jetBrainsMono(
                  color: AppColors.severityCritical,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 800.ms)
            else if (_isConnected)
              Text(
                tr(ref, 'systems_online'),
                style: GoogleFonts.jetBrainsMono(
                  color: AppColors.severityLow,
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 800.ms)
            else
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.accentBlue,
                ),
              ).animate().fadeIn(delay: 800.ms),
            const Spacer(),
            Text(
              'v1.0 HACKATHON BUILD',
              style: Theme.of(context).textTheme.labelSmall,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
