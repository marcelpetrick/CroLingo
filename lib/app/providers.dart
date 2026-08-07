import 'package:crolingo/data/progress/app_database.dart';
import 'package:crolingo/data/progress/drift_progress_repository.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Production database lifecycle.
final databaseProvider = Provider<AppDatabase>((ref) {
  final database = AppDatabase();
  ref.onDispose(database.close);
  return database;
});

/// Shared local progress repository.
final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => DriftProgressRepository(ref.watch(databaseProvider)),
);
