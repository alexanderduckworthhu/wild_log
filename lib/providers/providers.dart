import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/database/app_database.dart';
import '../data/session_repository.dart';
import '../domain/dashboard_stats.dart';
import '../domain/session.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository(ref.watch(databaseProvider));
});

final sessionsProvider = StreamProvider<List<AdventureSession>>((ref) {
  return ref.watch(sessionRepositoryProvider).watchAll();
});

final dashboardStatsProvider = Provider<AsyncValue<DashboardStats>>((ref) {
  return ref.watch(sessionsProvider).whenData(DashboardStats.fromSessions);
});

final shellTabProvider = StateProvider<int>((ref) => 0);

/// One-shot seed after DB is ready.
final seedProvider = FutureProvider<void>((ref) async {
  await ref.watch(databaseProvider).seedIfEmpty();
});
