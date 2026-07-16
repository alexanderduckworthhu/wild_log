import 'package:flutter/painting.dart';

/// Consistent spacing rhythm across Wild Log.
abstract final class WildSpace {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;

  /// Bottom padding so content clears the FAB + nav.
  static const scrollBottom = 120.0;

  static const pageInsets = EdgeInsets.fromLTRB(lg, 0, lg, scrollBottom);
}
