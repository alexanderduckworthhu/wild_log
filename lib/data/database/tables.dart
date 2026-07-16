import 'package:drift/drift.dart';

/// One row = one outdoor session.
/// Shared columns stay queryable; [detailsJson] holds activity-specific fields.
class Sessions extends Table {
  TextColumn get id => text()();
  TextColumn get activityType => text()();
  TextColumn get title => text()();
  DateTimeColumn get startedAt => dateTime()();
  IntColumn get durationMinutes => integer().withDefault(const Constant(0))();
  TextColumn get locationName => text().nullable()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get notes => text().nullable()();
  IntColumn get difficulty => integer().withDefault(const Constant(3))();

  /// Query-friendly shared metrics (nullable when N/A for activity).
  RealColumn get elevationGainM => real().nullable()();
  RealColumn get distanceKm => real().nullable()();

  /// JSON map of activity-specific fields (snow conditions, range distance, …).
  TextColumn get detailsJson => text().withDefault(const Constant('{}'))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
