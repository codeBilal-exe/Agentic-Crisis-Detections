import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'constants.dart';

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDeep,
    colorScheme: ColorScheme.dark(
      primary: AppColors.accentBlue,
      secondary: AppColors.accentCyan,
      surface: AppColors.bgCard,
    ),
    textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme).copyWith(
      displayLarge: GoogleFonts.spaceGrotesk(
        fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
        letterSpacing: -0.5,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, color: AppColors.textSecondary,
      ),
      labelSmall: GoogleFonts.jetBrainsMono(
        fontSize: 11, color: AppColors.textTertiary, letterSpacing: 0.5,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.bgCard,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.borderSubtle, width: 1),
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.bgDeep,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.spaceGrotesk(
        fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary,
      ),
    ),
  );
}
