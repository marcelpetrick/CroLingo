import 'package:crolingo/data/course/asset_course_repository.dart';
import 'package:crolingo/data/progress/app_database.dart';
import 'package:crolingo/data/progress/drift_progress_repository.dart';
import 'package:crolingo/data/speech/platform_speech_service.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:crolingo/domain/speech/speech_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Validated course snapshot bundled with this application version.
final courseProvider = FutureProvider<Course>(
  (ref) => AssetCourseRepository().load(),
);

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

/// Optional device-local Croatian pronunciation service.
final speechServiceProvider = Provider<SpeechService>(
  (ref) => PlatformSpeechService(),
);
