import 'dart:io';

import 'package:crolingo/data/speech/platform_speech_service.dart';
import 'package:crolingo/domain/speech/speech_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dispatches Croatian text to Android', () async {
    String? method;
    Object? arguments;
    final service = PlatformSpeechService(
      platform: SpeechPlatform.android,
      androidInvoker: (calledMethod, calledArguments) async {
        method = calledMethod;
        arguments = calledArguments;
        return 'spoken';
      },
    );

    expect(await service.speakCroatian('Bok!'), SpeechOutcome.spoken);
    expect(method, 'speakCroatian');
    expect(arguments, 'Bok!');
  });

  test('falls back from speech dispatcher to espeak on Linux', () async {
    final commands = <String>[];
    final service = PlatformSpeechService(
      platform: SpeechPlatform.linux,
      commandRunner: (executable, arguments) async {
        commands.add('$executable ${arguments.join(' ')}');
        return ProcessResult(1, executable == 'espeak-ng' ? 0 : 1, '', '');
      },
    );

    expect(await service.speakCroatian('Hvala.'), SpeechOutcome.spoken);
    expect(commands, [
      'spd-say --wait --language hr Hvala.',
      'espeak-ng -v hr Hvala.',
    ]);
  });

  test('reports missing Linux speech services without throwing', () async {
    final service = PlatformSpeechService(
      platform: SpeechPlatform.linux,
      commandRunner: (executable, arguments) =>
          throw ProcessException(executable, arguments),
    );

    expect(await service.speakCroatian('Molim.'), SpeechOutcome.unavailable);
    expect(await service.speakCroatian('  '), SpeechOutcome.failed);
  });

  test('maps Android outcomes and treats platform failures safely', () async {
    var result = 'unavailable';
    final service = PlatformSpeechService(
      platform: SpeechPlatform.android,
      androidInvoker: (method, arguments) async {
        if (result == 'exception') {
          throw PlatformException(code: 'tts-error');
        }
        return result;
      },
    );

    expect(await service.speakCroatian('Bok!'), SpeechOutcome.unavailable);
    result = 'unexpected';
    expect(await service.speakCroatian('Bok!'), SpeechOutcome.failed);
    result = 'exception';
    expect(await service.speakCroatian('Bok!'), SpeechOutcome.failed);
    await service.stop();
  });

  test('stops Android playback and ignores optional stop failures', () async {
    final calls = <String>[];
    final service = PlatformSpeechService(
      platform: SpeechPlatform.android,
      androidInvoker: (method, arguments) async {
        calls.add(method);
        return null;
      },
    );
    await service.stop();
    expect(calls, ['stop']);

    final failing = PlatformSpeechService(
      platform: SpeechPlatform.android,
      androidInvoker: (method, arguments) =>
          throw PlatformException(code: 'stop-error'),
    );
    await failing.stop();
  });

  test('selects Linux by default and tolerates failed commands', () async {
    final service = PlatformSpeechService(
      commandRunner: (executable, arguments) async =>
          ProcessResult(1, 1, '', ''),
    );

    expect(service.platform, SpeechPlatform.linux);
    expect(await service.speakCroatian('Da.'), SpeechOutcome.unavailable);
    await service.stop();
  });

  test('reports unsupported platforms without invoking an adapter', () async {
    final service = PlatformSpeechService(platform: SpeechPlatform.unsupported);

    expect(await service.speakCroatian('Ne.'), SpeechOutcome.unavailable);
    await service.stop();
  });
}
