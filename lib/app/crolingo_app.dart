import 'package:crolingo/app/providers.dart';
import 'package:crolingo/app/router.dart';
import 'package:crolingo/core/theme/app_theme.dart';
import 'package:crolingo/domain/settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Root application widget.
class CroLingoApp extends ConsumerWidget {
  /// Creates the CroLingo application.
  const CroLingoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // The settings stream also drives the appearance, so it must start before
    // the first frame rather than when a lesson opens.
    final variant = ref
        .watch(appSettingsProvider)
        .when(
          data: (settings) => settings.themeVariant,
          error: (error, stackTrace) => AppSettings.defaults.themeVariant,
          loading: () => AppSettings.defaults.themeVariant,
        );
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'CroLingo',
      theme: AppTheme.themeFor(variant),
      routerConfig: appRouter,
    );
  }
}
