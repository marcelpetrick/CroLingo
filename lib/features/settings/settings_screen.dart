import 'dart:async';

import 'package:crolingo/app/providers.dart';
import 'package:crolingo/core/theme/app_theme.dart';
import 'package:crolingo/domain/settings/app_settings.dart';
import 'package:crolingo/domain/settings/app_theme_variant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Local, durable learner preferences.
class SettingsScreen extends ConsumerWidget {
  /// Creates the settings screen.
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final value = settings.when(
      data: (data) => data.feedbackSoundsEnabled,
      error: (error, stackTrace) => AppSettings.defaults.feedbackSoundsEnabled,
      loading: () => AppSettings.defaults.feedbackSoundsEnabled,
    );
    final unlockAll = settings.when(
      data: (data) => data.developerUnlockAllLessons,
      error: (error, stackTrace) =>
          AppSettings.defaults.developerUnlockAllLessons,
      loading: () => AppSettings.defaults.developerUnlockAllLessons,
    );
    final reduceMotion = settings.when(
      data: (data) => data.reduceMotion,
      error: (error, stackTrace) => AppSettings.defaults.reduceMotion,
      loading: () => AppSettings.defaults.reduceMotion,
    );
    final variant = settings.when(
      data: (data) => data.themeVariant,
      error: (error, stackTrace) => AppSettings.defaults.themeVariant,
      loading: () => AppSettings.defaults.themeVariant,
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
      children: [
        Row(
          children: [
            IconButton(
              tooltip: 'Zurück',
              onPressed: context.pop,
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Einstellungen',
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          'Feedback & Bewegung',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile.adaptive(
            value: value,
            onChanged: settings.hasValue
                ? (enabled) => ref
                      .read(settingsRepositoryProvider)
                      .setFeedbackSoundsEnabled(enabled: enabled)
                : null,
            secondary: Icon(
              Icons.music_note_rounded,
              color: context.palette.primary,
            ),
            title: const Text('Ergebnistöne'),
            subtitle: const Text(
              'Spielt einen hellen Ping bei richtigen Antworten und einen '
              'Fehlerton bei falschen Antworten.',
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile.adaptive(
            value: reduceMotion,
            onChanged: settings.hasValue
                ? (enabled) => ref
                      .read(settingsRepositoryProvider)
                      .setReduceMotion(enabled: enabled)
                : null,
            secondary: Icon(
              Icons.motion_photos_off_outlined,
              color: context.palette.primary,
            ),
            title: const Text('Bewegungen reduzieren'),
            subtitle: const Text(
              'Schaltet dekorative Übergänge und Feieranimationen aus.',
            ),
          ),
        ),
        if (settings.hasError)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Die Einstellung konnte nicht geladen werden. Der sichere '
              'Standard bleibt aktiv.',
            ),
          ),
        const SizedBox(height: 16),
        Text('Darstellung', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        Card(
          child: RadioGroup<AppThemeVariant>(
            groupValue: variant,
            // RadioGroup requires a callback, so ignore selections until the
            // stored settings have loaded and the shown value is real.
            onChanged: (selected) {
              if (selected == null || !settings.hasValue) return;
              unawaited(
                ref.read(settingsRepositoryProvider).setThemeVariant(selected),
              );
            },
            child: Column(
              children: [
                for (final option in AppThemeVariant.values)
                  RadioListTile<AppThemeVariant>(
                    value: option,
                    secondary: Icon(
                      _themeIcon(option),
                      color: context.palette.primary,
                    ),
                    title: Text(_themeName(option)),
                    subtitle: Text(_themeDescription(option)),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Entwicklungseinstellungen',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile.adaptive(
            value: unlockAll,
            onChanged: settings.hasValue
                ? (enabled) => ref
                      .read(settingsRepositoryProvider)
                      .setDeveloperUnlockAllLessons(enabled: enabled)
                : null,
            secondary: Icon(
              Icons.lock_open_rounded,
              color: context.palette.accent,
            ),
            title: const Text('Gesperrte Lektionen öffnen'),
            subtitle: const Text(
              'Nur zum Testen: erlaubt das Starten noch nicht '
              'freigeschalteter Lektionen und umgeht damit die Reihenfolge '
              'des Lernwegs. Standardmäßig aus.',
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Die Einstellungen bleiben lokal auf diesem Gerät gespeichert '
            'und werden bei App-Updates übernommen.',
            style: TextStyle(color: context.palette.slate),
          ),
        ),
      ],
    );
  }
}

String _themeName(AppThemeVariant variant) => switch (variant) {
  AppThemeVariant.adriatic => 'Adria-Blau',
  AppThemeVariant.neonViolet => 'Neon-Violett',
  AppThemeVariant.midnight => 'Mitternacht',
  AppThemeVariant.mint => 'Minze',
  AppThemeVariant.highContrast => 'Hoher Kontrast',
};

String _themeDescription(AppThemeVariant variant) => switch (variant) {
  AppThemeVariant.adriatic => 'Das helle Standardaussehen von CroLingo.',
  AppThemeVariant.neonViolet => 'Dunkel mit leuchtenden violetten Akzenten.',
  AppThemeVariant.midnight => 'Tiefes Schwarz, schont den Akku auf OLED.',
  AppThemeVariant.mint => 'Helle, ruhige Grüntöne.',
  AppThemeVariant.highContrast =>
    'Maximaler Kontrast für Menschen mit Sehbeeinträchtigung.',
};

IconData _themeIcon(AppThemeVariant variant) => switch (variant) {
  AppThemeVariant.adriatic => Icons.water_rounded,
  AppThemeVariant.neonViolet => Icons.auto_awesome_rounded,
  AppThemeVariant.midnight => Icons.dark_mode_rounded,
  AppThemeVariant.mint => Icons.eco_rounded,
  AppThemeVariant.highContrast => Icons.contrast_rounded,
};
