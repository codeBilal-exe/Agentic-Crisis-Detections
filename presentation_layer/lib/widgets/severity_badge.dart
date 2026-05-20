import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants.dart';

class SeverityBadge extends StatelessWidget {
  final String severity;
  
  const SeverityBadge({super.key, required this.severity});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    switch (severity.toUpperCase()) {
      case 'CRITICAL': bgColor = AppColors.severityCritical; break;
      case 'HIGH': bgColor = AppColors.severityHigh; break;
      case 'MEDIUM': bgColor = AppColors.severityMedium; break;
      case 'LOW': bgColor = AppColors.severityLow; break;
      default: bgColor = AppColors.severityNone;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        severity.toUpperCase(),
        style: GoogleFonts.jetBrainsMono(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
