/// User-controlled preferences loaded from app-private storage.
class AppSettings {
  /// Creates an immutable settings snapshot.
  const AppSettings({required this.feedbackSoundsEnabled});

  /// Safe defaults used before a stored preference exists.
  static const defaults = AppSettings(feedbackSoundsEnabled: true);

  /// Plays distinct tones after correct and incorrect answers.
  final bool feedbackSoundsEnabled;
}

/// Persistent boundary for application preferences.
abstract interface class SettingsRepository {
  /// Emits the current settings and every subsequent change.
  Stream<AppSettings> watch();

  /// Loads one settings snapshot.
  Future<AppSettings> load();

  /// Persists the answer-feedback sound preference.
  Future<void> setFeedbackSoundsEnabled({required bool enabled});
}
