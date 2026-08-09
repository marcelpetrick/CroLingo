import 'dart:io';

import 'package:crolingo/data/progress/app_database.dart';
import 'package:crolingo/data/settings/drift_settings_repository.dart';
import 'package:crolingo/domain/settings/app_theme_variant.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'defaults to enabled and persists changes across database opens',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'crolingo-settings',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}/settings.sqlite');

      var database = AppDatabase(NativeDatabase(file));
      var repository = DriftSettingsRepository(database);
      expect((await repository.load()).feedbackSoundsEnabled, isTrue);

      await repository.setFeedbackSoundsEnabled(enabled: false);
      expect((await repository.watch().first).feedbackSoundsEnabled, isFalse);
      final rows = await database.select(database.appSettingEntries).get();
      expect(
        rows.where((row) => row.key == 'settings_format_version').single.value,
        '${DriftSettingsRepository.storageFormatVersion}',
      );
      await database.close();

      database = AppDatabase(NativeDatabase(file));
      repository = DriftSettingsRepository(database);
      expect((await repository.load()).feedbackSoundsEnabled, isFalse);
      await database.close();
    },
  );

  test('schema migration creates the extensible settings table', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    expect(database.schemaVersion, 2);
    await database.customStatement('DROP TABLE app_setting_entries');

    await database.migration.onUpgrade(
      database.createMigrator(),
      1,
      database.schemaVersion,
    );

    final tables = await database
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
          variables: const [Variable<String>('app_setting_entries')],
        )
        .get();
    expect(tables, hasLength(1));
  });

  test('falls back safely when a future or corrupt value is unknown', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database
        .into(database.appSettingEntries)
        .insert(
          AppSettingEntriesCompanion.insert(
            key: 'feedback_sounds_enabled',
            value: 'not-a-boolean',
          ),
        );

    final settings = await DriftSettingsRepository(database).load();

    expect(settings.feedbackSoundsEnabled, isTrue);
  });

  test('stores and restores the chosen appearance', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftSettingsRepository(database);

    expect((await repository.load()).themeVariant, AppThemeVariant.adriatic);

    await repository.setThemeVariant(AppThemeVariant.midnight);
    expect((await repository.load()).themeVariant, AppThemeVariant.midnight);

    // Changing one preference must not reset the other.
    await repository.setFeedbackSoundsEnabled(enabled: false);
    final settings = await repository.load();
    expect(settings.themeVariant, AppThemeVariant.midnight);
    expect(settings.feedbackSoundsEnabled, isFalse);
  });

  test('ignores an appearance this build does not know', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    await database
        .into(database.appSettingEntries)
        .insert(
          AppSettingEntriesCompanion.insert(
            key: 'theme_variant',
            value: 'sepia-from-a-later-release',
          ),
        );

    final settings = await DriftSettingsRepository(database).load();

    expect(settings.themeVariant, AppThemeVariant.adriatic);
  });

  test('keeps the developer unlock off unless it is switched on', () async {
    final database = AppDatabase(NativeDatabase.memory());
    addTearDown(database.close);
    final repository = DriftSettingsRepository(database);

    expect((await repository.load()).developerUnlockAllLessons, isFalse);

    await repository.setDeveloperUnlockAllLessons(enabled: true);
    expect((await repository.load()).developerUnlockAllLessons, isTrue);

    await repository.setDeveloperUnlockAllLessons(enabled: false);
    expect((await repository.load()).developerUnlockAllLessons, isFalse);
  });
}
