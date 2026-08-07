import 'dart:async';

import 'package:crolingo/app/providers.dart';
import 'package:crolingo/domain/settings/app_settings.dart';
import 'package:crolingo/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('persists the answer-tone switch and fits narrow text', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(320, 800)
      ..devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(() {
      tester.view.reset();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    final repository = _MemorySettingsRepository();
    addTearDown(repository.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Antworttöne'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(find.byType(Switch));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();

    expect(repository.current.feedbackSoundsEnabled, isFalse);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the safe default when settings cannot be loaded', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith(
            (ref) => Stream<AppSettings>.error(Exception('storage failed')),
          ),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('sichere Standard'), findsOneWidget);
    expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
    expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
  });
}

class _MemorySettingsRepository implements SettingsRepository {
  AppSettings current = AppSettings.defaults;
  final _changes = StreamController<AppSettings>.broadcast();

  @override
  Future<AppSettings> load() async => current;

  @override
  Stream<AppSettings> watch() async* {
    yield current;
    yield* _changes.stream;
  }

  @override
  Future<void> setFeedbackSoundsEnabled({required bool enabled}) async {
    current = AppSettings(feedbackSoundsEnabled: enabled);
    _changes.add(current);
  }

  Future<void> close() => _changes.close();
}
