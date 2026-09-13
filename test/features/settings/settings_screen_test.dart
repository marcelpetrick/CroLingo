import 'dart:async';

import 'package:crolingo/app/providers.dart';
import 'package:crolingo/domain/settings/app_settings.dart';
import 'package:crolingo/domain/settings/app_theme_variant.dart';
import 'package:crolingo/features/settings/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// The answer-tone switch, which is the first of the two on the screen.
final Finder soundSwitch = find.byType(Switch).first;

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
        overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ergebnistöne'), findsOneWidget);
    expect(find.textContaining('hellen Ping'), findsOneWidget);
    expect(find.textContaining('Fehlerton'), findsOneWidget);
    expect(tester.widget<Switch>(soundSwitch).value, isTrue);
    expect(tester.takeException(), isNull);

    await tester.ensureVisible(soundSwitch);
    await tester.pumpAndSettle();
    await tester.tap(soundSwitch);
    await tester.pumpAndSettle();

    expect(repository.current.feedbackSoundsEnabled, isFalse);
    expect(tester.widget<Switch>(soundSwitch).value, isFalse);
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
    expect(tester.widget<Switch>(soundSwitch).value, isTrue);
    expect(tester.widget<Switch>(soundSwitch).onChanged, isNull);
  });

  testWidgets('persists a chosen appearance', (tester) async {
    tester.view
      ..physicalSize = const Size(1236, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final repository = _MemorySettingsRepository();
    addTearDown(repository.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Darstellung'), findsOneWidget);
    expect(find.text('Hoher Kontrast'), findsOneWidget);
    expect(
      find.textContaining('Sehbeeinträchtigung'),
      findsOneWidget,
      reason: 'the accessibility option must say what it is for',
    );

    await tester.tap(find.text('Mitternacht'));
    await tester.pumpAndSettle();

    expect(repository.current.themeVariant, AppThemeVariant.midnight);
    expect(repository.current.feedbackSoundsEnabled, isTrue);
  });

  testWidgets('persists the reduced-motion preference', (tester) async {
    tester.view
      ..physicalSize = const Size(1236, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final repository = _MemorySettingsRepository();
    addTearDown(repository.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bewegungen reduzieren'));
    await tester.pumpAndSettle();

    expect(repository.current.reduceMotion, isTrue);
    expect(find.textContaining('Feieranimationen'), findsOneWidget);
  });

  testWidgets('shows safe defaults while settings are still loading', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1236, 3600)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          appSettingsProvider.overrideWith(
            (ref) => const Stream<AppSettings>.empty(),
          ),
        ],
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();

    expect(tester.widget<Switch>(soundSwitch).value, isTrue);
    expect(find.text('Adria-Blau'), findsOneWidget);
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
    current = AppSettings(
      feedbackSoundsEnabled: enabled,
      reduceMotion: current.reduceMotion,
      themeVariant: current.themeVariant,
      developerUnlockAllLessons: current.developerUnlockAllLessons,
    );
    _changes.add(current);
  }

  @override
  Future<void> setReduceMotion({required bool enabled}) async {
    current = AppSettings(
      feedbackSoundsEnabled: current.feedbackSoundsEnabled,
      reduceMotion: enabled,
      themeVariant: current.themeVariant,
      developerUnlockAllLessons: current.developerUnlockAllLessons,
    );
    _changes.add(current);
  }

  @override
  Future<void> setDeveloperUnlockAllLessons({required bool enabled}) async {
    current = AppSettings(
      feedbackSoundsEnabled: current.feedbackSoundsEnabled,
      reduceMotion: current.reduceMotion,
      themeVariant: current.themeVariant,
      developerUnlockAllLessons: enabled,
    );
    _changes.add(current);
  }

  @override
  Future<void> setThemeVariant(AppThemeVariant variant) async {
    current = AppSettings(
      feedbackSoundsEnabled: current.feedbackSoundsEnabled,
      reduceMotion: current.reduceMotion,
      themeVariant: variant,
      developerUnlockAllLessons: current.developerUnlockAllLessons,
    );
    _changes.add(current);
  }

  Future<void> close() => _changes.close();
}
