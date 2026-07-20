import 'package:flutter/material.dart';

/// Alpine night kit, muted sage / sandstone / glacier, not acid-green-on-black.
///
/// Tokens live here so widgets never hardcode hex values.
abstract final class WildColors {
  static const voidBlack = Color(0xFF0B0F0D);
  static const charcoal = Color(0xFF141A17);
  static const ridge = Color(0xFF1E2621);
  static const moss = Color(0xFF2C3831);
  static const sage = Color(0xFF8A9A7C);
  static const sageDim = Color(0xFF5A6B52);
  static const sandstone = Color(0xFFC9956A);
  static const glacier = Color(0xFF7FA4B3);
  static const bone = Color(0xFFE8EDE8);
  static const mist = Color(0xFFA0ADA4);
  static const danger = Color(0xFFC45C4A);
  static const trail = Color(0xFF3A4A41);

  /// Primary interactive / life signal.
  static const Color primary = sage;

  /// Secondary heat signal (difficulty, PRs).
  static const Color accent = sandstone;

  /// Cool metric signal (distance, snow).
  static const Color cool = glacier;

  // Backward-compatible aliases used across the app.
  static const Color lichen = sage;
  static const Color lichenDim = sageDim;
  static const Color ember = sandstone;
  static const Color ice = glacier;

  static const camp = Color(0xFFB8A06A);
  static const shoot = Color(0xFFA87A5C);
  static const hunt = Color(0xFF6F8A74);
  static const jetski = Color(0xFF5A96A8);

  /// Returns the accent color for an activity type id.
  static Color forActivity(String type) {
    return switch (type) {
      'hike' => sage,
      'climb' => sandstone,
      'snowboard' => glacier,
      'camp' => camp,
      'shoot' => shoot,
      'hunt' => hunt,
      'jetski' => jetski,
      _ => mist,
    };
  }
}
