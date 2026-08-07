import 'dart:io';

import 'package:crolingo/domain/speech/speech_service.dart';
import 'package:flutter/services.dart';

/// Runtime platform selected for speech dispatch.
enum SpeechPlatform {
  /// Android system TextToSpeech.
  android,

  /// Linux speech dispatcher or eSpeak.
  linux,

  /// A platform outside the supported release targets.
  unsupported,
}

/// Replaceable Android method invocation.
typedef AndroidSpeechInvoker =
    Future<Object?> Function(
      String method,
      Object? arguments,
    );

/// Replaceable local command invocation.
typedef SpeechCommandRunner =
    Future<ProcessResult> Function(
      String executable,
      List<String> arguments,
    );

/// Android system TTS and Linux local-command implementation.
class PlatformSpeechService implements SpeechService {
  /// Creates a production service or a deterministic test adapter.
  PlatformSpeechService({
    SpeechPlatform? platform,
    AndroidSpeechInvoker? androidInvoker,
    SpeechCommandRunner? commandRunner,
  }) : platform = platform ?? _currentPlatform(),
       _androidInvoker = androidInvoker ?? _invokeAndroid,
       _commandRunner = commandRunner ?? Process.run;

  static const _channel = MethodChannel('it.marcelpetrick.crolingo/speech');

  /// Active runtime target.
  final SpeechPlatform platform;
  final AndroidSpeechInvoker _androidInvoker;
  final SpeechCommandRunner _commandRunner;

  @override
  Future<SpeechOutcome> speakCroatian(String text) async {
    final value = text.trim();
    if (value.isEmpty) return SpeechOutcome.failed;
    return switch (platform) {
      SpeechPlatform.android => _speakAndroid(value),
      SpeechPlatform.linux => _speakLinux(value),
      SpeechPlatform.unsupported => Future.value(SpeechOutcome.unavailable),
    };
  }

  Future<SpeechOutcome> _speakAndroid(String text) async {
    try {
      final result = await _androidInvoker('speakCroatian', text);
      return switch (result) {
        'spoken' => SpeechOutcome.spoken,
        'unavailable' => SpeechOutcome.unavailable,
        _ => SpeechOutcome.failed,
      };
    } on PlatformException {
      return SpeechOutcome.failed;
    }
  }

  Future<SpeechOutcome> _speakLinux(String text) async {
    for (final command in const [
      ('spd-say', ['--wait', '--language', 'hr']),
      ('espeak-ng', ['-v', 'hr']),
    ]) {
      try {
        final result = await _commandRunner(command.$1, [
          ...command.$2,
          text,
        ]);
        if (result.exitCode == 0) return SpeechOutcome.spoken;
      } on ProcessException {
        // Try the next local speech service.
      }
    }
    return SpeechOutcome.unavailable;
  }

  @override
  Future<void> stop() async {
    if (platform != SpeechPlatform.android) return;
    try {
      await _androidInvoker('stop', null);
    } on PlatformException {
      // Stopping optional playback is best-effort.
    }
  }

  static Future<Object?> _invokeAndroid(
    String method,
    Object? arguments,
  ) => _channel.invokeMethod<Object?>(method, arguments);

  static SpeechPlatform _currentPlatform() {
    if (Platform.isAndroid) return SpeechPlatform.android;
    if (Platform.isLinux) return SpeechPlatform.linux;
    return SpeechPlatform.unsupported;
  }
}
