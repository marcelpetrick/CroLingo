import 'dart:io';

import 'package:crolingo/data/progress/app_database.dart';
import 'package:crolingo/data/settings/drift_settings_repository.dart';
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
}
