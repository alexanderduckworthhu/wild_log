import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'wild_colors.dart';

abstract final class WildTheme {
  static ThemeData dark() {
    final display = GoogleFonts.barlowCondensedTextTheme();
    final body = GoogleFonts.ibmPlexSansTextTheme();

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: WildColors.voidBlack,
      focusColor: WildColors.sage.withValues(alpha: 0.24),
      highlightColor: WildColors.sage.withValues(alpha: 0.12),
      colorScheme: const ColorScheme.dark(
        surface: WildColors.charcoal,
        primary: WildColors.sage,
        secondary: WildColors.ember,
        tertiary: WildColors.ice,
        onPrimary: WildColors.voidBlack,
        onSecondary: WildColors.voidBlack,
        onSurface: WildColors.bone,
        error: WildColors.danger,
        outline: WildColors.trail,
      ),
      dividerColor: WildColors.trail,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.barlowCondensed(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.4,
          color: WildColors.bone,
        ),
        iconTheme: const IconThemeData(color: WildColors.bone),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: WildColors.sage,
        foregroundColor: WildColors.voidBlack,
        elevation: 0,
        shape: RoundedRectangleBorder(),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: WildColors.moss,
        contentTextStyle: GoogleFonts.ibmPlexSans(color: WildColors.bone),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: WildColors.ridge,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: WildColors.trail),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: WildColors.trail),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(2),
          borderSide: const BorderSide(color: WildColors.sage, width: 1.5),
        ),
        labelStyle: GoogleFonts.ibmPlexSans(color: WildColors.mist, fontSize: 13),
        hintStyle: GoogleFonts.ibmPlexSans(color: WildColors.mist.withValues(alpha: 0.6)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: WildColors.ridge,
        selectedColor: WildColors.sageDim,
        labelStyle: GoogleFonts.ibmPlexSans(color: WildColors.bone, fontSize: 12),
        side: const BorderSide(color: WildColors.trail),
        shape: const RoundedRectangleBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: WildColors.charcoal,
        selectedItemColor: WildColors.sage,
        unselectedItemColor: WildColors.mist,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );

    return base.copyWith(
      textTheme: body
          .apply(
            bodyColor: WildColors.bone,
            displayColor: WildColors.bone,
          )
          .copyWith(
            displayLarge: display.displayLarge?.copyWith(
              fontFamily: GoogleFonts.barlowCondensed().fontFamily,
              color: WildColors.bone,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
            displayMedium: display.displayMedium?.copyWith(
              fontFamily: GoogleFonts.barlowCondensed().fontFamily,
              color: WildColors.bone,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
            headlineLarge: GoogleFonts.barlowCondensed(
              fontSize: 36,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
              color: WildColors.bone,
            ),
            headlineMedium: GoogleFonts.barlowCondensed(
              fontSize: 28,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.8,
              color: WildColors.bone,
            ),
            headlineSmall: GoogleFonts.barlowCondensed(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              letterSpacing: 2,
              color: WildColors.bone,
            ),
            titleLarge: GoogleFonts.barlowCondensed(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.6,
              color: WildColors.bone,
            ),
            titleMedium: GoogleFonts.ibmPlexSans(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: WildColors.bone,
            ),
            bodyLarge: GoogleFonts.ibmPlexSans(
              fontSize: 15,
              height: 1.45,
              color: WildColors.bone,
            ),
            bodyMedium: GoogleFonts.ibmPlexSans(
              fontSize: 13,
              height: 1.4,
              color: WildColors.mist,
            ),
            labelLarge: GoogleFonts.barlowCondensed(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              letterSpacing: 2.2,
              color: WildColors.sage,
            ),
            labelSmall: GoogleFonts.ibmPlexSans(
              fontSize: 11,
              letterSpacing: 0.8,
              color: WildColors.mist,
            ),
          ),
    );
  }
}
