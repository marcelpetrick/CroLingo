import 'package:crolingo/app/providers.dart';
import 'package:crolingo/core/theme/app_colors.dart';
import 'package:crolingo/domain/settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Local, durable learner preferences.
class SettingsScreen extends ConsumerWidget {
  /// Creates the settings screen.
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final value = settings.when(
      data: (data) => data.feedbackSoundsEnabled,
      error: (error, stackTrace) => AppSettings.defaults.feedbackSoundsEnabled,
      loading: () => AppSettings.defaults.feedbackSoundsEnabled,
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
        Card(
          child: SwitchListTile.adaptive(
            value: value,
            onChanged: settings.hasValue
                ? (enabled) => ref
                      .read(settingsRepositoryProvider)
                      .setFeedbackSoundsEnabled(enabled: enabled)
                : null,
            secondary: const Icon(
              Icons.music_note_rounded,
              color: AppColors.primary,
            ),
            title: const Text('Antworttöne'),
            subtitle: const Text(
              'Spielt einen freundlichen Ton bei richtigen und falschen '
              'Antworten.',
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
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'Die Einstellung bleibt lokal auf diesem Gerät gespeichert und '
            'wird bei App-Updates übernommen.',
            style: TextStyle(color: AppColors.slate),
          ),
        ),
      ],
    );
  }
}
