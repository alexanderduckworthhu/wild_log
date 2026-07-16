import 'dart:convert';

import 'activity_type.dart';

class AdventureSession {
  const AdventureSession({
    required this.id,
    required this.activityType,
    required this.title,
    required this.startedAt,
    required this.durationMinutes,
    this.locationName,
    this.latitude,
    this.longitude,
    this.notes,
    required this.difficulty,
    this.elevationGainM,
    this.distanceKm,
    this.details = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final ActivityType activityType;
  final String title;
  final DateTime startedAt;
  final int durationMinutes;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final String? notes;
  final int difficulty; // 1–5
  final double? elevationGainM;
  final double? distanceKm;
  final Map<String, dynamic> details;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get hasMapPin => latitude != null && longitude != null;

  String detailsAsJson() => jsonEncode(details);

  AdventureSession copyWith({
    String? id,
    ActivityType? activityType,
    String? title,
    DateTime? startedAt,
    int? durationMinutes,
    String? locationName,
    double? latitude,
    double? longitude,
    String? notes,
    int? difficulty,
    double? elevationGainM,
    double? distanceKm,
    Map<String, dynamic>? details,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AdventureSession(
      id: id ?? this.id,
      activityType: activityType ?? this.activityType,
      title: title ?? this.title,
      startedAt: startedAt ?? this.startedAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      notes: notes ?? this.notes,
      difficulty: difficulty ?? this.difficulty,
      elevationGainM: elevationGainM ?? this.elevationGainM,
      distanceKm: distanceKm ?? this.distanceKm,
      details: details ?? this.details,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
