import 'package:crolingo/data/progress/app_database.dart';
import 'package:crolingo/domain/settings/app_settings.dart';
import 'package:crolingo/domain/settings/app_theme_variant.dart';

/// Drift-backed, app-private preference storage.
class DriftSettingsRepository implements SettingsRepository {
  /// Creates a repository using the shared application database.
  const DriftSettingsRepository(this.database);

  /// Database schema version 2 introduced the extensible key/value table.
  static const storageFormatVersion = 1;

  static const _formatVersionKey = 'settings_format_version';
  static const _feedbackSoundsKey = 'feedback_sounds_enabled';
  static const _themeVariantKey = 'theme_variant';

  /// Shared database.
  final AppDatabase database;

  @override
  Future<AppSettings> load() async {
    final rows = await database.select(database.appSettingEntries).get();
    return _decode(rows);
  }

  @override
  Stream<AppSettings> watch() =>
      database.select(database.appSettingEntries).watch().map(_decode);

  @override
  Future<void> setFeedbackSoundsEnabled({required bool enabled}) =>
      _write(_feedbackSoundsKey, '$enabled');

  @override
  Future<void> setThemeVariant(AppThemeVariant variant) =>
      _write(_themeVariantKey, variant.name);

  Future<void> _write(String key, String value) async {
    await database.batch((batch) {
      batch.insertAllOnConflictUpdate(database.appSettingEntries, [
        AppSettingEntriesCompanion.insert(
          key: _formatVersionKey,
          value: '$storageFormatVersion',
        ),
        AppSettingEntriesCompanion.insert(key: key, value: value),
      ]);
    });
  }

  AppSettings _decode(List<AppSettingEntry> rows) {
    final values = {for (final row in rows) row.key: row.value};
    return AppSettings(
      feedbackSoundsEnabled: switch (values[_feedbackSoundsKey]) {
        'false' => false,
        'true' || null => true,
        _ => AppSettings.defaults.feedbackSoundsEnabled,
      },
      themeVariant: AppThemeVariant.fromStorage(values[_themeVariantKey]),
    );
  }
}
