import 'package:crolingo/app/providers.dart';
import 'package:crolingo/domain/speech/speech_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Accessible control for optional Croatian pronunciation playback.
class SpeechButton extends ConsumerStatefulWidget {
  /// Creates a playback button for one Croatian string.
  const SpeechButton({required this.text, this.service, super.key});

  /// Croatian text sent to the platform speech service.
  final String text;

  /// Optional deterministic service for isolated hosts and tests.
  final SpeechService? service;

  @override
  ConsumerState<SpeechButton> createState() => _SpeechButtonState();
}

class _SpeechButtonState extends ConsumerState<SpeechButton> {
  bool _busy = false;
  String? _announcement;

  Future<void> _speak() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _announcement = 'Wiedergabe wird gestartet';
    });
    final outcome = await _service().speakCroatian(widget.text);
    if (!mounted) return;
    final announcement = switch (outcome) {
      SpeechOutcome.spoken => 'Kroatische Aussprache wiedergegeben',
      SpeechOutcome.unavailable => 'Keine kroatische Stimme verfügbar',
      SpeechOutcome.failed => 'Aussprache konnte nicht wiedergegeben werden',
    };
    setState(() {
      _busy = false;
      _announcement = announcement;
    });
    if (outcome != SpeechOutcome.spoken) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$announcement.')),
      );
    }
  }

  SpeechService _service() => widget.service ?? ref.read(speechServiceProvider);

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    value: _announcement,
    child: IconButton(
      tooltip: 'Kroatisch anhören: ${widget.text}',
      onPressed: _busy ? null : _speak,
      icon: _busy
          ? const SizedBox.square(
              dimension: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.volume_up_rounded),
    ),
  );
}
