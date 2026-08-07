import 'package:crolingo/data/audio/asset_feedback_audio_service.dart';
import 'package:crolingo/domain/audio/feedback_audio_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps outcomes to distinct bundled assets', () async {
    final player = _RecordingPlayer();
    final service = AssetFeedbackAudioService(player: player);

    await service.play(AnswerFeedbackSound.success);
    await service.play(AnswerFeedbackSound.failure);
    await service.dispose();

    expect(player.assets, ['audio/success.wav', 'audio/failure.wav']);
    expect(player.disposed, isTrue);
  });

  test('audio failures never interrupt the lesson', () async {
    final service = AssetFeedbackAudioService(player: _FailingPlayer());

    await expectLater(
      service.play(AnswerFeedbackSound.success),
      completes,
    );
  });
}

class _RecordingPlayer implements FeedbackAssetPlayer {
  final assets = <String>[];
  bool disposed = false;

  @override
  Future<void> play(String assetPath) async => assets.add(assetPath);

  @override
  Future<void> dispose() async => disposed = true;
}

class _FailingPlayer implements FeedbackAssetPlayer {
  @override
  Future<void> play(String assetPath) async => throw Exception('no audio');

  @override
  Future<void> dispose() async {}
}
