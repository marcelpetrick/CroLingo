/// Answer outcome represented by a short, nonverbal sound.
enum AnswerFeedbackSound {
  /// Accepted answer.
  success,

  /// Answer that needs another attempt.
  failure,
}

/// Replaceable boundary for optional, offline feedback audio.
abstract interface class FeedbackAudioService {
  /// Plays the tone for [sound] without affecting grading.
  Future<void> play(AnswerFeedbackSound sound);

  /// Releases platform audio resources.
  Future<void> dispose();
}
