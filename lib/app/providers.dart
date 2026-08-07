import 'package:crolingo/data/audio/asset_feedback_audio_service.dart';
import 'package:crolingo/data/course/asset_course_repository.dart';
import 'package:crolingo/data/progress/app_database.dart';
import 'package:crolingo/data/progress/drift_progress_repository.dart';
import 'package:crolingo/data/settings/drift_settings_repository.dart';
import 'package:crolingo/data/speech/platform_speech_service.dart';
import 'package:crolingo/domain/audio/feedback_audio_service.dart';
import 'package:crolingo/domain/course/course.dart';
import 'package:crolingo/domain/progress/progress_repository.dart';
import 'package:crolingo/domain/settings/app_settings.dart';
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

/// Durable application preferences.
final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => DriftSettingsRepository(ref.watch(databaseProvider)),
);

/// Reactive settings loaded when the application starts.
final appSettingsProvider = StreamProvider<AppSettings>(
  (ref) => ref.watch(settingsRepositoryProvider).watch(),
);

/// Optional answer-outcome tones shared by lesson screens.
final feedbackAudioServiceProvider = Provider<FeedbackAudioService>((ref) {
  final service = AssetFeedbackAudioService();
  ref.onDispose(service.dispose);
  return service;
});

/// Optional device-local Croatian pronunciation service.
final speechServiceProvider = Provider<SpeechService>(
  (ref) => PlatformSpeechService(),
);
