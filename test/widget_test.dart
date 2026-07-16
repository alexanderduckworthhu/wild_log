import 'package:flutter_test/flutter_test.dart';

import 'package:wild_log/domain/activity_type.dart';
import 'package:wild_log/domain/dashboard_stats.dart';
import 'package:wild_log/domain/session.dart';

void main() {
  test('DashboardStats computes streak and type counts', () {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day, 10);
    final sessions = [
      AdventureSession(
        id: '1',
        activityType: ActivityType.hike,
        title: 'A',
        startedAt: today,
        durationMinutes: 60,
        difficulty: 3,
        elevationGainM: 400,
        createdAt: today,
        updatedAt: today,
      ),
      AdventureSession(
        id: '2',
        activityType: ActivityType.climb,
        title: 'B',
        startedAt: today.subtract(const Duration(days: 1)),
        durationMinutes: 90,
        difficulty: 4,
        elevationGainM: 200,
        createdAt: today,
        updatedAt: today,
      ),
    ];

    final stats = DashboardStats.fromSessions(sessions);
    expect(stats.totalSessions, 2);
    expect(stats.sessionsByType[ActivityType.hike], 1);
    expect(stats.currentStreakDays, greaterThanOrEqualTo(1));
    expect(stats.records, isNotEmpty);
  });
}
