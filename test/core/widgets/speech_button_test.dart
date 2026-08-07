import 'package:crolingo/core/widgets/speech_button.dart';
import 'package:crolingo/domain/speech/speech_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('plays the exact Croatian string', (tester) async {
    final service = _FakeSpeechService(SpeechOutcome.spoken);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SpeechButton(text: 'Kako si?', service: service),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Kroatisch anhören: Kako si?'));
    await tester.pumpAndSettle();
    expect(service.spoken, ['Kako si?']);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
  });

  testWidgets('explains when no Croatian voice is available', (tester) async {
    final service = _FakeSpeechService(SpeechOutcome.unavailable);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SpeechButton(text: 'Bok!', service: service),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Kroatisch anhören: Bok!'));
    await tester.pumpAndSettle();
    expect(find.text('Keine kroatische Stimme verfügbar.'), findsOneWidget);
  });

  testWidgets('explains a failed playback attempt', (tester) async {
    final service = _FakeSpeechService(SpeechOutcome.failed);
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: SpeechButton(text: 'Da.', service: service),
          ),
        ),
      ),
    );

    await tester.tap(find.byTooltip('Kroatisch anhören: Da.'));
    await tester.pumpAndSettle();
    expect(
      find.text('Aussprache konnte nicht wiedergegeben werden.'),
      findsOneWidget,
    );
  });
}

class _FakeSpeechService implements SpeechService {
  _FakeSpeechService(this.outcome);

  final SpeechOutcome outcome;
  final spoken = <String>[];

  @override
  Future<SpeechOutcome> speakCroatian(String text) async {
    spoken.add(text);
    return outcome;
  }

  @override
  Future<void> stop() async {}
}
