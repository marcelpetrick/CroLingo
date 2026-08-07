/// Result of an optional pronunciation playback request.
enum SpeechOutcome {
  /// The platform accepted and played the text.
  spoken,

  /// No Croatian voice or local speech service is installed.
  unavailable,

  /// The platform speech service failed unexpectedly.
  failed,
}

/// Platform-independent boundary for generated Croatian speech.
abstract interface class SpeechService {
  /// Speaks [text] using the Croatian locale without a network requirement.
  Future<SpeechOutcome> speakCroatian(String text);

  /// Stops platform speech when supported.
  Future<void> stop();
}
