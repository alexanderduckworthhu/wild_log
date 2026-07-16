/// Named limits and layout timing used across Wild Log.
abstract final class AppConstants {
  /// Difficulty scale lower bound (inclusive).
  static const minDifficulty = 1;

  /// Difficulty scale upper bound (inclusive).
  static const maxDifficulty = 5;

  /// Default session length when logging a new day (minutes).
  static const defaultDurationMinutes = 120;

  /// Earliest year accepted in the session date picker.
  static const earliestLogYear = 2018;

  /// Map default center when no pinned sessions exist (lat).
  static const defaultMapLatitudeDegrees = 49.9;

  /// Map default center when no pinned sessions exist (lng).
  static const defaultMapLongitudeDegrees = -122.8;

  /// Initial OSM zoom for the expedition map.
  static const defaultMapZoom = 7.2;

  /// Marker hit target size (logical pixels).
  static const mapMarkerSizePx = 44.0;

  /// Soft entrance animation length (milliseconds).
  static const enterAnimationMs = 380;

  /// Stagger step between list item entrances (milliseconds).
  static const listStaggerStepMs = 30;

  /// Cap on list entrance stagger (milliseconds).
  static const listStaggerMaxMs = 180;

  /// Milestone session-count targets shown on Summit.
  static const sessionMilestoneTargets = [5, 10, 25, 50, 100];

  /// Day-streak target for the secondary Summit milestone.
  static const weekStreakTargetDays = 7;

  /// Latitude valid range (degrees).
  static const minLatitudeDegrees = -90.0;
  static const maxLatitudeDegrees = 90.0;

  /// Longitude valid range (degrees).
  static const minLongitudeDegrees = -180.0;
  static const maxLongitudeDegrees = 180.0;

  /// OpenStreetMap tile endpoint (free public tiles; respect usage policy).
  static const osmTileUrlTemplate =
      'https://tile.openstreetmap.org/{z}/{x}/{y}.png';

  /// Package name sent as OSM User-Agent.
  static const osmUserAgentPackageName = 'com.alexanderduckworth.wild_log';
}
