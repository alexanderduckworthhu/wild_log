import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/activity_type.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Sessions])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
      : super(executor ?? driftDatabase(name: 'wild_log'));

  @override
  int get schemaVersion => 1;

  Future<void> seedIfEmpty() async {
    final count = await sessions.count().getSingle();
    if (count > 0) return;

    final now = DateTime.now();
    final uuid = const Uuid();

    final seeds = <SessionsCompanion>[
      _seed(
        uuid,
        ActivityType.hike,
        'Skyline ridgeline — morning push',
        now.subtract(const Duration(days: 1)),
        210,
        'Banff National Park',
        51.4968,
        -115.9281,
        3,
        elevation: 820,
        distance: 14.2,
        details: {'trailName': 'Skyline Trail (section)'},
        notes: 'Cold start. Found quiet above the treeline — that INFJ reset.',
      ),
      _seed(
        uuid,
        ActivityType.snowboard,
        'Powder day — north bowls',
        now.subtract(const Duration(days: 3)),
        300,
        'Whistler Blackcomb',
        50.1163,
        -122.9574,
        4,
        elevation: 1100,
        details: {
          'verticalDropM': 1100,
          'snowConditions': 'Fresh powder, 18cm overnight',
          'resort': 'Whistler',
        },
        notes: 'First chair. Zero phones. Full presence.',
      ),
      _seed(
        uuid,
        ActivityType.climb,
        'Multi-pitch afternoon',
        now.subtract(const Duration(days: 5)),
        180,
        'Squamish — The Chief',
        49.6833,
        -123.1500,
        4,
        elevation: 340,
        details: {'routeGrade': '5.9', 'pitches': 4},
        notes: 'Trusted the belay. Trust is the whole sport.',
      ),
      _seed(
        uuid,
        ActivityType.camp,
        'Two nights under the pines',
        now.subtract(const Duration(days: 8)),
        2880,
        'Garibaldi Provincial Park',
        49.9563,
        -123.0044,
        2,
        details: {'nightsOut': 2, 'siteName': 'Taylor Meadows'},
        notes: 'Stars dense enough to feel small in the right way.',
      ),
      _seed(
        uuid,
        ActivityType.shoot,
        'Zero confirmation — 200m',
        now.subtract(const Duration(days: 10)),
        90,
        'Local outdoor range',
        49.2500,
        -122.9000,
        3,
        details: {
          'rangeDistanceM': 200,
          'firearmType': 'Bolt rifle',
          'roundsFired': 40,
        },
        notes: 'Discipline over ego. Groups tightened mid-session.',
      ),
      _seed(
        uuid,
        ActivityType.hunt,
        'Dawn glassing — ridge sit',
        now.subtract(const Duration(days: 14)),
        360,
        'Interior highland',
        50.2000,
        -120.8000,
        3,
        details: {'terrain': 'Alpine fringe', 'gameType': 'Glass only'},
        notes: 'Patience as practice. The land decides the tempo.',
      ),
      _seed(
        uuid,
        ActivityType.jetski,
        'Coastal throttle — clear water',
        now.subtract(const Duration(days: 18)),
        75,
        'Sunshine Coast inlet',
        49.4800,
        -123.7600,
        2,
        distance: 28,
        details: {'waterConditions': 'Flat morning chop'},
        notes: 'Speed as play, not escape.',
      ),
      _seed(
        uuid,
        ActivityType.hike,
        'Night ridge — stargazing finish',
        now.subtract(const Duration(days: 21)),
        160,
        'Cypress Mountain',
        49.3950,
        -123.2044,
        3,
        elevation: 480,
        distance: 9.5,
        details: {'trailName': 'Howe Sound Crest (partial)'},
        notes: 'Bioluminescence on the bucket list. Tonight was rehearsal.',
      ),
    ];

    await batch((b) => b.insertAll(sessions, seeds));
  }

  SessionsCompanion _seed(
    Uuid uuid,
    ActivityType type,
    String title,
    DateTime startedAt,
    int durationMinutes,
    String location,
    double lat,
    double lng,
    int difficulty, {
    double? elevation,
    double? distance,
    Map<String, Object?> details = const {},
    String? notes,
  }) {
    final stamp = DateTime.now();
    return SessionsCompanion.insert(
      id: uuid.v4(),
      activityType: type.id,
      title: title,
      startedAt: startedAt,
      durationMinutes: Value(durationMinutes),
      locationName: Value(location),
      latitude: Value(lat),
      longitude: Value(lng),
      difficulty: Value(difficulty),
      elevationGainM: Value(elevation),
      distanceKm: Value(distance),
      detailsJson: Value(jsonEncode(details)),
      notes: Value(notes),
      createdAt: stamp,
      updatedAt: stamp,
    );
  }
}
