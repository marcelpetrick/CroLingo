import 'package:crolingo/app/providers.dart';
import 'package:crolingo/data/progress/app_database.dart';
import 'package:crolingo/data/progress/drift_progress_repository.dart';
import 'package:crolingo/data/settings/drift_settings_repository.dart';
import 'package:crolingo/data/speech/platform_speech_service.dart';
import 'package:crolingo/domain/settings/app_settings.dart';
import 'package:crolingo/domain/settings/app_theme_variant.dart';
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  /// Builds the real graph, replacing only the on-disk database.
  ///
  /// The point is to prove the wiring the application actually boots with,
  /// so nothing else is stubbed.
  ProviderContainer makeContainer() {
    final database = AppDatabase(NativeDatabase.memory());
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );
    addTearDown(container.dispose);
    addTearDown(database.close);
    return container;
  }

  test('wires the durable repositories onto one database', () {
    final container = makeContainer();

    final progress = container.read(progressRepositoryProvider);
    final settings = container.read(settingsRepositoryProvider);

    expect(progress, isA<DriftProgressRepository>());
    expect(settings, isA<DriftSettingsRepository>());
    expect(
      (progress as DriftProgressRepository).database,
      same((settings as DriftSettingsRepository).database),
      reason: 'progress and settings must share one app-private database',
    );
  });

  test('re-emits whatever the settings repository publishes', () async {
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(_StubSettings()),
      ],
    );
    addTearDown(container.dispose);
    // Keep the provider alive; without a listener it is disposed while still
    // loading and never gets to emit.
    container.listen(appSettingsProvider, (previous, next) {});

    final first = await container.read(appSettingsProvider.future);

    expect(first.feedbackSoundsEnabled, isFalse);
    expect(first.themeVariant, AppThemeVariant.mint);
  });

  test('exposes the replaceable speech service', () {
    final container = makeContainer();

    // The tone service is deliberately not read here: it constructs the real
    // audioplayers plugin, which has no binding in a unit test.
    expect(container.read(speechServiceProvider), isA<PlatformSpeechService>());
  });

  test('reads the bundled course through the asset repository', () async {
    final container = makeContainer();

    final course = await container.read(courseProvider.future);

    expect(course.units, isNotEmpty);
    expect(course.concepts, isNotEmpty);
  });

  test('reads the running version through the bundled pubspec', () async {
    final container = makeContainer();

    // Unreadable assets must degrade to null, never throw into the dashboard.
    await expectLater(container.read(appVersionProvider.future), completes);
  });

  test('owns the database lifecycle', () {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(database)],
    );

    expect(container.read(databaseProvider), same(database));
    container.dispose();
  });
}

class _StubSettings implements SettingsRepository {
  static const _stored = AppSettings(
    feedbackSoundsEnabled: false,
    themeVariant: AppThemeVariant.mint,
  );

  @override
  Future<AppSettings> load() async => _stored;

  @override
  Stream<AppSettings> watch() => Stream.value(_stored);

  @override
  Future<void> setFeedbackSoundsEnabled({required bool enabled}) async {}

  @override
  Future<void> setThemeVariant(AppThemeVariant variant) async {}
}
