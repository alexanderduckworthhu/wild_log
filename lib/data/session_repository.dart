import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../core/constants/app_constants.dart';
import '../core/errors/repository_exception.dart';
import '../domain/activity_type.dart';
import '../domain/session.dart';
import 'database/app_database.dart';

/// Persists [AdventureSession] rows in the local Drift/SQLite store.
class SessionRepository {
  SessionRepository(this._db);

  final AppDatabase _db;
  final _uuid = const Uuid();

  /// Emits all sessions newest-first whenever the table changes.
  Stream<List<AdventureSession>> watchAll() {
    try {
      final query = _db.select(_db.sessions)
        ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
      return query.watch().map((rows) => rows.map(_fromRow).toList());
    } on Exception catch (error, stackTrace) {
      return Stream.error(
        RepositoryException('Failed to watch sessions', cause: error),
        stackTrace,
      );
    }
  }

  /// Returns a single session by [id], or null if missing.
  Future<AdventureSession?> getById(String id) async {
    try {
      final row =
          await (_db.select(_db.sessions)..where((t) => t.id.equals(id)))
              .getSingleOrNull();
      return row == null ? null : _fromRow(row);
    } on Exception catch (error) {
      throw RepositoryException('Failed to load session $id', cause: error);
    }
  }

  /// Inserts or updates [session]; returns the persisted id.
  Future<String> upsert(AdventureSession session) async {
    try {
      final id = session.id.isEmpty ? _uuid.v4() : session.id;
      final now = DateTime.now();
      final companion = SessionsCompanion(
        id: Value(id),
        activityType: Value(session.activityType.id),
        title: Value(session.title),
        startedAt: Value(session.startedAt),
        durationMinutes: Value(session.durationMinutes),
        locationName: Value(session.locationName),
        latitude: Value(session.latitude),
        longitude: Value(session.longitude),
        notes: Value(session.notes),
        difficulty: Value(
          session.difficulty.clamp(
            AppConstants.minDifficulty,
            AppConstants.maxDifficulty,
          ),
        ),
        elevationGainM: Value(session.elevationGainM),
        distanceKm: Value(session.distanceKm),
        detailsJson: Value(session.detailsAsJson()),
        createdAt: Value(
          session.createdAt.millisecondsSinceEpoch == 0
              ? now
              : session.createdAt,
        ),
        updatedAt: Value(now),
      );
      await _db.into(_db.sessions).insertOnConflictUpdate(companion);
      return id;
    } on Exception catch (error) {
      throw RepositoryException('Failed to save session', cause: error);
    }
  }

  /// Deletes the session with [id].
  Future<void> delete(String id) async {
    try {
      await (_db.delete(_db.sessions)..where((t) => t.id.equals(id))).go();
    } on Exception catch (error) {
      throw RepositoryException('Failed to delete session $id', cause: error);
    }
  }

  /// Maps a Drift row to the domain entity, tolerating corrupt details JSON.
  AdventureSession _fromRow(Session row) {
    final details = _decodeDetails(row.detailsJson);
    return AdventureSession(
      id: row.id,
      activityType: ActivityType.fromId(row.activityType),
      title: row.title,
      startedAt: row.startedAt,
      durationMinutes: row.durationMinutes,
      locationName: row.locationName,
      latitude: row.latitude,
      longitude: row.longitude,
      notes: row.notes,
      difficulty: row.difficulty,
      elevationGainM: row.elevationGainM,
      distanceKm: row.distanceKm,
      details: details,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  /// Parses activity-specific JSON; returns {} if the payload is invalid.
  Map<String, dynamic> _decodeDetails(String rawJson) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) {
        return decoded.map((key, value) => MapEntry(key.toString(), value));
      }
      return {};
    } on FormatException {
      return {};
    }
  }
}
