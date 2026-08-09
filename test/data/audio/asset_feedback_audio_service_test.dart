import 'dart:io';
import 'dart:typed_data';

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

  test('bundled cues are distinct and have audible safe peaks', () async {
    final success = File('assets/audio/success.wav').readAsBytesSync();
    final failure = File('assets/audio/failure.wav').readAsBytesSync();

    expect(success, isNot(orderedEquals(failure)));
    expect(_peakPcm16(success), inInclusiveRange(12000, 28000));
    expect(_peakPcm16(failure), inInclusiveRange(12000, 28000));
  });

  test('a failing release never escapes teardown', () async {
    // Found by the integration suite: the real plugin raises when released a
    // second time, and that must not surface where the service is disposed.
    final service = AssetFeedbackAudioService(player: _ThrowingOnDispose());

    await expectLater(service.dispose(), completes);
  });
}

int _peakPcm16(Uint8List wav) {
  final data = ByteData.sublistView(wav);
  var offset = 12;
  while (offset + 8 <= wav.length) {
    final chunk = String.fromCharCodes(wav.sublist(offset, offset + 4));
    final size = data.getUint32(offset + 4, Endian.little);
    final start = offset + 8;
    if (chunk == 'data') {
      var peak = 0;
      for (var sample = start; sample + 1 < start + size; sample += 2) {
        final magnitude = data.getInt16(sample, Endian.little).abs();
        if (magnitude > peak) peak = magnitude;
      }
      return peak;
    }
    offset = start + size + (size.isOdd ? 1 : 0);
  }
  throw const FormatException('WAV file has no data chunk');
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

class _ThrowingOnDispose implements FeedbackAssetPlayer {
  @override
  Future<void> play(String assetPath) async {}

  @override
  Future<void> dispose() async => throw Exception('already disposed');
}
