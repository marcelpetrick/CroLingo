import 'dart:io';

import 'package:crolingo/data/speech/platform_speech_service.dart';
import 'package:crolingo/domain/speech/speech_service.dart';
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
}
