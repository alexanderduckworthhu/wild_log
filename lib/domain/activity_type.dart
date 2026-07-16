import 'package:flutter/material.dart';

import '../core/theme/wild_colors.dart';

enum ActivityType {
  hike,
  climb,
  snowboard,
  camp,
  shoot,
  hunt,
  jetski,
  other;

  String get id => name;

  String get label => switch (this) {
        hike => 'Hike',
        climb => 'Climb',
        snowboard => 'Snowboard',
        camp => 'Camp',
        shoot => 'Range',
        hunt => 'Hunt',
        jetski => 'Jet Ski',
        other => 'Other',
      };

  IconData get icon => switch (this) {
        hike => Icons.terrain_outlined,
        climb => Icons.filter_hdr_outlined,
        snowboard => Icons.ac_unit_outlined,
        camp => Icons.nightlight_round,
        shoot => Icons.gps_fixed,
        hunt => Icons.park_outlined,
        jetski => Icons.water_outlined,
        other => Icons.explore_outlined,
      };

  Color get color => WildColors.forActivity(id);

  /// Shared + activity-specific field keys shown in the log form.
  List<ActivityFieldSpec> get specificFields => switch (this) {
        hike => const [
          ActivityFieldSpec('elevationGainM', 'Elevation gain (m)', FieldKind.number),
          ActivityFieldSpec('distanceKm', 'Distance (km)', FieldKind.number),
          ActivityFieldSpec('trailName', 'Trail name', FieldKind.text),
        ],
        climb => const [
          ActivityFieldSpec('elevationGainM', 'Elevation gain (m)', FieldKind.number),
          ActivityFieldSpec('routeGrade', 'Route grade', FieldKind.text),
          ActivityFieldSpec('pitches', 'Pitches', FieldKind.number),
        ],
        snowboard => const [
          ActivityFieldSpec('verticalDropM', 'Vertical drop (m)', FieldKind.number),
          ActivityFieldSpec('snowConditions', 'Snow conditions', FieldKind.text),
          ActivityFieldSpec('resort', 'Resort / zone', FieldKind.text),
        ],
        camp => const [
          ActivityFieldSpec('nightsOut', 'Nights out', FieldKind.number),
          ActivityFieldSpec('siteName', 'Site name', FieldKind.text),
        ],
        shoot => const [
          ActivityFieldSpec('rangeDistanceM', 'Range distance (m)', FieldKind.number),
          ActivityFieldSpec('firearmType', 'Firearm / platform', FieldKind.text),
          ActivityFieldSpec('roundsFired', 'Rounds fired', FieldKind.number),
        ],
        hunt => const [
          ActivityFieldSpec('terrain', 'Terrain', FieldKind.text),
          ActivityFieldSpec('gameType', 'Game / quarry', FieldKind.text),
        ],
        jetski => const [
          ActivityFieldSpec('distanceKm', 'Distance (km)', FieldKind.number),
          ActivityFieldSpec('waterConditions', 'Water conditions', FieldKind.text),
        ],
        other => const [
          ActivityFieldSpec('customMetric', 'Custom metric note', FieldKind.text),
        ],
      };

  static ActivityType fromId(String id) {
    return ActivityType.values.firstWhere(
      (e) => e.id == id,
      orElse: () => ActivityType.other,
    );
  }
}

enum FieldKind { text, number }

class ActivityFieldSpec {
  const ActivityFieldSpec(this.key, this.label, this.kind);
  final String key;
  final String label;
  final FieldKind kind;
}
