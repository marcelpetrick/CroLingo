import 'package:crolingo/domain/settings/app_theme_variant.dart';

/// User-controlled preferences loaded from app-private storage.
class AppSettings {
  /// Creates an immutable settings snapshot.
  const new({
    required this.feedbackSoundsEnabled,
    required this.reduceMotion,
    required this.themeVariant,
    required this.developerUnlockAllLessons,
  });

  /// Safe defaults used before a stored preference exists.
  static const defaults = AppSettings(
    feedbackSoundsEnabled: true,
    reduceMotion: false,
    themeVariant: AppThemeVariant.adriatic,
    developerUnlockAllLessons: false,
  );

  /// Plays distinct tones after correct and incorrect answers.
  final bool feedbackSoundsEnabled;

  /// Disables decorative transitions while preserving state feedback.
  final bool reduceMotion;

  /// Selected application appearance.
  final AppThemeVariant themeVariant;

  /// Opens every lesson, including ones the learner has not unlocked.
  ///
  /// This is a debugging aid for reaching later content directly. It bypasses
  /// sequential progression, so it stays off unless explicitly enabled.
  final bool developerUnlockAllLessons;
}

/// Persistent boundary for application preferences.
abstract interface class SettingsRepository {
  /// Emits the current settings and every subsequent change.
  Stream<AppSettings> watch();

  /// Loads one settings snapshot.
  Future<AppSettings> load();

  /// Persists the answer-feedback sound preference.
  Future<void> setFeedbackSoundsEnabled({required bool enabled});

  /// Persists whether decorative movement is reduced.
  Future<void> setReduceMotion({required bool enabled});

  /// Persists the selected appearance.
  Future<void> setThemeVariant(AppThemeVariant variant);

  /// Persists whether locked lessons may be opened.
  Future<void> setDeveloperUnlockAllLessons({required bool enabled});
}
