import 'package:crolingo/data/audio/asset_feedback_audio_service.dart';
import 'package:crolingo/data/progress/app_database.dart';
import 'package:crolingo/data/progress/drift_progress_repository.dart';
import 'package:crolingo/data/settings/drift_settings_repository.dart';
import 'package:crolingo/data/speech/platform_speech_service.dart';
import 'package:crolingo/domain/audio/feedback_audio_service.dart';
import 'package:crolingo/domain/settings/app_theme_variant.dart';
import 'package:crolingo/domain/speech/speech_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

/// Exercises the boundaries a headless unit test cannot reach.
///
/// Everything here needs a real platform: the audio plugin, the system speech
/// facility, and an on-disk database opened through `path_provider`. These are
/// exactly the lines that stay uncovered in `flutter test`, and the only
/// honest way to check them is to run the app on a device or desktop.
///
/// Run with `./scripts/run_integration_tests.sh`.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('feedback tones', () {
    test('play both outcomes through the real plugin', () async {
      final service = AssetFeedbackAudioService();
      addTearDown(service.dispose);

      // The learner must never lose a lesson to an audio failure, so these
      // complete even when the host has no working audio device.
      await service.play(AnswerFeedbackSound.success);
      await service.play(AnswerFeedbackSound.failure);
    });

    test('survive being disposed twice', () async {
      final service = AssetFeedbackAudioService();
      await service.dispose();

      await expectLater(service.dispose(), completes);
    });
  });

  group('Croatian speech', () {
    test('reports an outcome instead of throwing', () async {
      final service = PlatformSpeechService();
      addTearDown(service.stop);

      final outcome = await service.speakCroatian('Dobar dan!');

      // A missing hr-HR voice is a normal result, not a failure.
      expect(SpeechOutcome.values, contains(outcome));
    });

    test('detects the host platform', () {
      final platform = PlatformSpeechService().platform;

      expect(
        platform,
        anyOf(SpeechPlatform.android, SpeechPlatform.linux),
        reason: 'CroLingo only ships for Android and Linux',
      );
    });
  });

  group('app-private database', () {
    test('opens on disk and round-trips real progress', () async {
      final database = AppDatabase();
      addTearDown(database.close);
      final progress = DriftProgressRepository(database);
      final settings = DriftSettingsRepository(database);

      await progress.recordAttempt(
        lessonId: 'integration',
        exerciseId: 'integration-1',
        submittedAnswer: 'Bok!',
        correct: true,
        incorrectBefore: 0,
        occurredAt: DateTime.now().toUtc(),
      );
      await settings.setThemeVariant(AppThemeVariant.midnight);

      final attempts = await progress.loadAttemptHistory();
      final stored = await settings.load();

      expect(
        attempts.where((a) => a.exerciseId == 'integration-1'),
        isNotEmpty,
      );
      expect(stored.themeVariant, AppThemeVariant.midnight);
    });
  });
}
