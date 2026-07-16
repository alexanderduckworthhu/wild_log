import '../core/constants/app_constants.dart';
import '../core/l10n/app_strings.dart';
import 'activity_type.dart';
import 'session.dart';

class PersonalRecord {
  const PersonalRecord({
    required this.label,
    required this.value,
    required this.unit,
    required this.sessionTitle,
  });

  final String label;
  final String value;
  final String unit;
  final String sessionTitle;
}

class Milestone {
  const Milestone({
    required this.title,
    required this.detail,
    required this.progress,
    required this.target,
  });

  final String title;
  final String detail;
  final int progress;
  final int target;

  /// Progress ratio in 0..1 for progress bars.
  double get ratio => target == 0 ? 0 : (progress / target).clamp(0, 1);
}

/// Aggregates streak, volume, records, and the next milestone from sessions.
class DashboardStats {
  const DashboardStats({
    required this.currentStreakDays,
    required this.longestStreakDays,
    required this.totalSessions,
    required this.sessionsByType,
    required this.totalElevationM,
    required this.totalDistanceKm,
    required this.records,
    required this.nextMilestone,
  });

  final int currentStreakDays;
  final int longestStreakDays;
  final int totalSessions;
  final Map<ActivityType, int> sessionsByType;
  final double totalElevationM;
  final double totalDistanceKm;
  final List<PersonalRecord> records;
  final Milestone nextMilestone;

  /// Builds Summit metrics from a session list; empty list yields zeroed stats.
  static DashboardStats fromSessions(List<AdventureSession> sessions) {
    if (sessions.isEmpty) {
      return const DashboardStats(
        currentStreakDays: 0,
        longestStreakDays: 0,
        totalSessions: 0,
        sessionsByType: {},
        totalElevationM: 0,
        totalDistanceKm: 0,
        records: [],
        nextMilestone: Milestone(
          title: AppStrings.firstWaypointTitle,
          detail: AppStrings.firstWaypointDetail,
          progress: 0,
          target: 1,
        ),
      );
    }

    final sessionsByType = <ActivityType, int>{};
    var totalElevationM = 0.0;
    var totalDistanceKm = 0.0;
    AdventureSession? highestElevationSession;
    AdventureSession? longestDistanceSession;
    AdventureSession? hardestSession;

    for (final session in sessions) {
      sessionsByType[session.activityType] =
          (sessionsByType[session.activityType] ?? 0) + 1;
      totalElevationM += session.elevationGainM ?? 0;
      totalDistanceKm += session.distanceKm ?? 0;
      if (session.elevationGainM != null &&
          (highestElevationSession == null ||
              session.elevationGainM! >
                  (highestElevationSession.elevationGainM ?? 0))) {
        highestElevationSession = session;
      }
      if (session.distanceKm != null &&
          (longestDistanceSession == null ||
              session.distanceKm! >
                  (longestDistanceSession.distanceKm ?? 0))) {
        longestDistanceSession = session;
      }
      if (hardestSession == null ||
          session.difficulty > hardestSession.difficulty) {
        hardestSession = session;
      }
    }

    final streaks = _calendarDayStreaks(sessions);
    final records = <PersonalRecord>[
      if (highestElevationSession != null)
        PersonalRecord(
          label: AppStrings.recordHighestGain,
          value: highestElevationSession.elevationGainM!.round().toString(),
          unit: AppStrings.unitMeters,
          sessionTitle: highestElevationSession.title,
        ),
      if (longestDistanceSession != null)
        PersonalRecord(
          label: AppStrings.recordLongestDistance,
          value: longestDistanceSession.distanceKm!.toStringAsFixed(1),
          unit: AppStrings.unitKilometers,
          sessionTitle: longestDistanceSession.title,
        ),
      if (hardestSession != null)
        PersonalRecord(
          label: AppStrings.recordHardest,
          value:
              '${hardestSession.difficulty}/${AppConstants.maxDifficulty}',
          unit: AppStrings.recordDiffUnit,
          sessionTitle: hardestSession.title,
        ),
    ];

    return DashboardStats(
      currentStreakDays: streaks.$1,
      longestStreakDays: streaks.$2,
      totalSessions: sessions.length,
      sessionsByType: sessionsByType,
      totalElevationM: totalElevationM,
      totalDistanceKm: totalDistanceKm,
      records: records,
      nextMilestone: _nextMilestone(sessions.length, streaks.$1),
    );
  }

  /// Returns `(currentStreakDays, longestStreakDays)` on calendar days.
  static (int, int) _calendarDayStreaks(List<AdventureSession> sessions) {
    final activityDays = sessions
        .map(
          (session) => DateTime(
            session.startedAt.year,
            session.startedAt.month,
            session.startedAt.day,
          ),
        )
        .toSet()
        .toList()
      ..sort();

    if (activityDays.isEmpty) return (0, 0);

    var longestStreakDays = 1;
    var runLength = 1;
    for (var index = 1; index < activityDays.length; index++) {
      final gapDays =
          activityDays[index].difference(activityDays[index - 1]).inDays;
      if (gapDays == 1) {
        runLength += 1;
        if (runLength > longestStreakDays) longestStreakDays = runLength;
      } else if (gapDays > 1) {
        runLength = 1;
      }
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final mostRecentDay = activityDays.last;

    if (mostRecentDay != today && mostRecentDay != yesterday) {
      return (0, longestStreakDays);
    }

    var currentStreakDays = 1;
    for (var index = activityDays.length - 1; index > 0; index--) {
      if (activityDays[index].difference(activityDays[index - 1]).inDays ==
          1) {
        currentStreakDays += 1;
      } else {
        break;
      }
    }
    return (currentStreakDays, longestStreakDays);
  }

  /// Chooses the next motivational target from session count, then streak.
  static Milestone _nextMilestone(int totalSessions, int currentStreakDays) {
    for (final target in AppConstants.sessionMilestoneTargets) {
      if (totalSessions < target) {
        return Milestone(
          title: AppStrings.sessionsMilestoneTitle(target),
          detail: AppStrings.sessionsMilestoneDetail(totalSessions),
          progress: totalSessions,
          target: target,
        );
      }
    }
    if (currentStreakDays < AppConstants.weekStreakTargetDays) {
      return Milestone(
        title: AppStrings.weekStreakTitle,
        detail: currentStreakDays == 0
            ? AppStrings.weekStreakCold
            : AppStrings.weekStreakWarm,
        progress: currentStreakDays,
        target: AppConstants.weekStreakTargetDays,
      );
    }
    return Milestone(
      title: AppStrings.keepFireTitle,
      detail: AppStrings.keepFireDetail,
      progress: totalSessions,
      target: totalSessions + 10,
    );
  }
}
