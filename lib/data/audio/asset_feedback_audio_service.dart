import 'package:audioplayers/audioplayers.dart';
import 'package:crolingo/domain/audio/feedback_audio_service.dart';

/// Small player boundary that keeps the platform plugin injectable in tests.
abstract interface class FeedbackAssetPlayer {
  /// Stops any prior tone and plays one bundled asset.
  Future<void> play(String assetPath);

  /// Releases plugin resources.
  Future<void> dispose();
}

/// Android/Linux player backed by the endorsed audioplayers implementations.
class AudioplayersFeedbackAssetPlayer implements FeedbackAssetPlayer {
  final AudioPlayer _player = AudioPlayer(playerId: 'answer-feedback');

  @override
  Future<void> play(String assetPath) async {
    await _player.stop();
    await _player.play(AssetSource(assetPath), mode: PlayerMode.lowLatency);
  }

  @override
  Future<void> dispose() => _player.dispose();
}

/// Plays original, bundled success and retry tones fully offline.
class AssetFeedbackAudioService implements FeedbackAudioService {
  /// Creates the production service or accepts an isolated test player.
  AssetFeedbackAudioService({FeedbackAssetPlayer? player})
    : _player = player ?? AudioplayersFeedbackAssetPlayer();

  static const _successAsset = 'audio/success.wav';
  static const _failureAsset = 'audio/failure.wav';

  final FeedbackAssetPlayer _player;

  @override
  Future<void> play(AnswerFeedbackSound sound) async {
    final asset = switch (sound) {
      AnswerFeedbackSound.success => _successAsset,
      AnswerFeedbackSound.failure => _failureAsset,
    };
    try {
      await _player.play(asset);
    } on Exception {
      // Feedback audio is an enhancement and must never block a lesson.
    }
  }

  @override
  Future<void> dispose() => _player.dispose();
}
